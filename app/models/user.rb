require 'digest/sha1'
class User < ActiveRecord::Base
  include GeocodingUtilities
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  cattr_accessor :current_user

  belongs_to :state
  has_many :commitments
  has_many :events, :through => :commitments
  has_many :permissions
  has_many :calendars, :through => :permissions
  # validates_presence_of :permissions
  composed_of :address, :mapping => [%w(street street), %w(street2 street2), %w(city city), %w(state_id state), %w(zip zip), %w(coords coords)]
  
  validates_presence_of :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 1..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  before_save :make_feed_key
  before_save :encrypt_password
  before_create :make_activation_code
  after_create :set_calendar
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :firstname, :lastname, :street, :street2, :city, :state_id, :zip, :show_contact
  
  def admin?
    @admin ||= Role.find_by_name('admin')
    !(self.permissions.find_by_role_id(@admin).nil?)
  end
  
  def country
    return self.state.nil? ? nil : self.state.country
  end
  
  def coords
    c = self[:coords]
    if c.nil?
      if self.state_id.nil? then
        return nil
      end
      begin
        c = coords_from_string(address.to_s(:geo))
        self[:coords] = c
        self.save
      rescue
        c = Point.from_x_y(0, 0)   
      else
      end
    end
    c
  end
  
  # Compares users by last name, first name, and e-mail address in that order.
  # ['Smith', 'John', 'jsmith1@aol.com'] < ['Smith', 'John', 'jsmith2@aol.com']
  def <=>(other)
    attrs = [:lastname, :firstname, :email]
    attrs.collect{|a| self[a].downcase rescue nil}.compact <=> attrs.collect{|a| other[a].downcase rescue nil}.compact
  end

  # Returns the user's name as a string. Order can be :first_last (default) or :last_first. E-mail address will be returned if no name is specified.
  def to_s(format = :first_last)
    case format
    when :first_last
      str = [self.firstname, self.lastname].delete_if {|e| e.blank?}.join(' ')
    when :last_first
      str = [self.lastname, self.firstname].delete_if {|e| e.blank?}.join(', ')
    else
      raise ArgumentError, "format must be :first_last, :last_first, or blank"
    end
    str.blank? ? self.email : str
  end

  ##### The stuff below here comes from restful_authentication.

  # Activates the user in the database.
  def activate
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  # Authenticates a user by their login e-mail address and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, password)
    u = find :first, :conditions => ['email = ? and activated_at IS NOT NULL', email] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{email}--") if new_record?
      self.crypted_password = encrypt(password)
    end
      
    def password_required?
      crypted_password.blank? || !password.blank? || !password_confirmation.blank?
    end
    
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def make_feed_key
      if self.feed_key.blank?
        self.feed_key = Digest::MD5.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
      end
    end
    
    def set_calendar
      if Calendar.count == 1
        self.permissions << Permission.create(:user => self, :calendar => Calendar.find(:first), :role => Role.find_or_create_by_name('user'))
      end
    end
end

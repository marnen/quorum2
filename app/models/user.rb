require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.transition_from_restful_authentication = true
  end
  
  include GeocodingUtilities
  cattr_accessor :current_user

  belongs_to :state
  has_many :commitments
  has_many :events, :through => :commitments
  has_many :permissions
  has_many :calendars, :through => :permissions
  # validates_presence_of :permissions
  composed_of :address, :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]}
  
  validates_presence_of :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 1..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  before_save :make_single_access_token
  before_update :clear_coords
  after_create :set_calendar
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password, :password_confirmation, :firstname, :lastname, :street, :street2, :city, :state_id, :zip, :show_contact
  
  # Sets the User's active status to true.
  # TODO: Rename to activate! , since it's destructive.
  def activate
    update_attribute(:active, true)
  end
  
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
  
  # Resets the user's password and password_confirmation to a random string. Designed to be used for password resets.
  def reset_password!
    new_password = Digest::MD5.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)[0, 10]
    self.password = new_password
    self.password_confirmation = new_password
    save!
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

  protected
    def password_required?
      crypted_password.blank? || !password.blank? || !password_confirmation.blank?
    end
    
    def make_single_access_token
      if single_access_token.blank?
        reset_single_access_token!
      end
    end
    
    def set_calendar
      if Calendar.count == 1
        self.permissions << Permission.create(:user => self, :calendar => Calendar.find(:first), :role => Role.find_or_create_by_name('user'))
      end
    end
end

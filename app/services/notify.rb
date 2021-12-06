class Notify
  attr_reader :response

  def initialize
  end

  def update(response)
    @response = OpenStruct.new(response: response)
    display
  end

  def display
    p "======== Notify ========= "
    p @response
    p "========================= "
  end
end

class ConcreteSubject
  attr_reader :obj

  def initialize(obj)
    @observers = []
    @obj = obj
  end

  def attach(observer)
    @observers << observer
  end

  def detach(observer)
    @observers.delete(observer)
  end

  def notify
    @observers.each { |observer| observer.update(@obj) }
  end
end
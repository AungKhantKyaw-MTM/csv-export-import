class MyFirstJob
  include Sidekiq::Job

  def perform(name, age = 23)
    # Do something
    puts "Hello I am #{name}, and my name is #{age} years old!"
  end
end

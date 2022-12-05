# frozen_string_literal: true
require 'histogram/array'
require 'csv'
module Triangular
  # Creat a CSV file to save the outputs
  @csv = CSV.open("Output.csv", "w")
  def Triangular.export_to_csv(bins , freqs, method_name)

    @csv << [method_name]
    @csv << bins
    @csv << freqs
  end

  #puts(ARGV[0])
  def Triangular.get_random(min, max)
    return rand * (max - min) + min
  end

  def Triangular.pdf(x, a, b, c)
    if x < a
      output = 0
    elsif  x >= a and x <= c
      output = (2 * (x - a)) / ((b - a) * (c - a))
    elsif   x > c and x <= b
      (2 * (b - x)) / ((b - a) * (b - c))
    else
      output = 0
    return output
    end
  end

  def Triangular.matematics(samples)

    mean = samples.sum(0.0) / samples.size
    sum = samples.sum(0.0) { |element| (element - mean) ** 2 }
    variance = sum / (samples.size - 1)
    standard_deviation = Math.sqrt(variance)
    @csv << ["Mean", "Standard_deviation", "Variance"]
    @csv << [mean,standard_deviation,variance]
    @csv << [""]
  end

  ## Main Methods
  def Triangular.inverse_method(a, b, c, number_of_experiments)
    #interval = [a,b]
    # c = mode
    step = 1.0/number_of_experiments
    samples_a = []
    fc = (c - a) / (b - a)
    Range.new(0,fc).step(step) {|x| samples_a.push(x)}
    #puts (a)
    samples_a = samples_a.map { |i| a + Math.sqrt(i *(b - a) * (c - a)) }

    samples_b = []
    #Range.new(1-(2.0-c)**2/2.0,1 + -1*(2.0-b)**2/2.0).step(step) {|x| b.push(x)}
    Range.new(fc,1).step(step) {|x| samples_b.push(x)}
    #puts (b)
    samples_b = samples_b.map { |i| b - Math.sqrt((1 - i) * (b - a) * (b - c)) }
    samples_c = samples_a+samples_b

    #puts("size is")
    #puts(samples_c.size)
    (bins, freqs) = samples_c.histogram

    export_to_csv bins, freqs, "Triangular Distribution Inverse Method"
    matematics samples_c
  end


  def Triangular.metropolis_method(a, b, c, number_of_experiments)

    samples = []

    burn_in = (number_of_experiments*0.2).to_int
    # We increase number of expriments by 20%, because at the end we want to remove 20% of them
    number_of_experiments = (number_of_experiments * 1.2).to_int

    # choose a random number between min and max
    max = b
    min = a
    current = Triangular.get_random min,max
    for i in 1..number_of_experiments do
      samples.push(current)
      movement = Triangular.get_random min,max

      curr_prob = Triangular.pdf(current,a,b,c)
      move_prob = Triangular.pdf(movement,a,b,c)

      acceptance = [move_prob/curr_prob,1].min
      if acceptance > rand
        current = movement
      end
    end
    # burn the initial results since they was not so accurate
    samples = samples[burn_in..]
    (bins, freqs) = samples.histogram
    Triangular.export_to_csv bins, freqs,"Triangular Distribution: Metropolise Method"
    matematics samples
  end

  def Triangular.neyman_method(a, b, c, number_of_experiments)
    # neyman or accept and reject method
    maximum_of_pdf = 2/(b-a)

    samples = []
    while samples.length < number_of_experiments do
      x = Triangular.get_random a, b
      y = Triangular.get_random 0, maximum_of_pdf
      pdf = Triangular.pdf(x,a,b,c)
      if y <= pdf
        samples.push(x)
      end
    end
    (bins, freqs) = samples.histogram
    export_to_csv bins, freqs, "Triangular Distribution: Neyman or Rejection Method"
    matematics samples
  end

  puts("\nЦя програма – генератор випадкової величини за допомогою методів зворотньої функції, Неймана та Метрополіса.
Щоб почати роботу з програмою введіть значення параметрів функції розподілу: нижню межу a, верхню межу b і моду c, щоб штучно обмежити функцію.
Введіть бажану кількість експериментів n. Якщо якісь параметри будуть введені некоректно, користувача попросять ввести їх знову.
Після закінчення обчислень у файлі Output.csv відобразяться значення гістограми щільності ймовірності розподілу.
Також з’являться чисельні дані: математичне очікування, дисперсія та середньоквадратичне відхилення.
Вищенаведені дані у графічному вигляді знаходяться у файлі Output_final.xlsx")
  puts("\nРозробниця програми: Калмикова Катерина, група КС-42, Харків-2022")

  puts("\n\nTo simulate the Triangular distribution enter these parameters:")
  print "a="
  STDOUT.flush
  a = gets.chomp.to_f
  print "b="
  STDOUT.flush
  b = gets.chomp.to_f
  while a >= b
    puts("b should be greater than a")
    print "b="
    STDOUT.flush
    b = gets.chomp.to_f
  end
  print "c="
  STDOUT.flush
  c = gets.chomp.to_f
  while c <= a or c >= b
    puts("c is the mode. it should be in [a,b]")
    print "c="
    STDOUT.flush
    c = gets.chomp.to_f
  end
  print "Number of experiments(Samples)="
  STDOUT.flush
  n = (gets.chomp).to_i
  while n < 10000
    puts("Number of experiments should be greater than 9999")
    print "n="
    STDOUT.flush
    n = gets.chomp.to_i
    end


  inverse_method a,b,c,n
  metropolis_method a,b,c,n
  neyman_method a,b,c,n

  #inverse_method 0.0,5.0,4.0,1000
  #metropolis_method 0.0, 5.0, 4.0,20000
  #neyman_method 0.0, 5.0, 4.0,5000

  puts("\nThe results are stored at the output.csv file.")
  puts("\nIf you want to run this code again make sure you close output.csv first.")


end

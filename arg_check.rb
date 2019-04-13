# Class that validates command line input arguments
class ArgumentCheck
  def arg_check(args)
    args.count == 1
  rescue StandardError
    false
  end
end

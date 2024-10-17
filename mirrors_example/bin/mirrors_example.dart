import 'package:mirrors_example/mirrors_example.dart';

void main(List<String> arguments) {
  var myObject = MyClass();

  // Use the contract proxy to automatically apply contracts
  var proxy = ContractProxy(myObject);

  // This will run the doubleValue method with contract checks applied
  var result = proxy.invoke(#multiplyValueByPositive, [2]);
  
  print(result); // Should output 200

  proxy.invoke(#multiplyValueByPositive, [-2]); // Precondition fails
}

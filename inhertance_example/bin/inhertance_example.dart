import '../lib/contract.dart';

class Account extends Contract {
  int balance = 100;

  @override
  Map<String, bool> get invariantAsserts => {
        'balance must be positive': balance > 0,
      };

  void deposit(int sum) {
    final oldBalance = balance;
    require({
      'sum must be > 0': sum > 0,
    });

    balance += sum;
    ensure({
      'balance should increase': balance - oldBalance == sum,
    });
  }
}

void main(List<String> arguments) {
  final a = Account();
  a.deposit(100);
}

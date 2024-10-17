import 'dart:mirrors';

// annotations
class HasPreconditions {
  const HasPreconditions();
}

class HasPostconditions {
  const HasPostconditions();
}

const HasPostconditions hasPostconditions = HasPostconditions();
const HasPreconditions hasPreconditions = HasPreconditions();

// registry for preconditions and postconditions
// TODO invariants
class ContractRegistry {
  static final Map<Symbol, List<bool Function(List<dynamic>)>> _preconditions =
      {};
  static final Map<Symbol, List<bool Function(dynamic result)>>
      _postconditions = {};

  static void registerPrecondition(
      Symbol methodName, bool Function(List<dynamic>) condition) {
    if (!_preconditions.containsKey(methodName)) {
      _preconditions[methodName] = [];
    }
    _preconditions[methodName]?.add(condition);
  }

  static void registerPostcondition(
      Symbol methodName, bool Function(dynamic result) condition) {
    if (!_postconditions.containsKey(methodName)) {
      _postconditions[methodName] = [];
    }
    _postconditions[methodName]?.add(condition);
  }

  static List<bool Function(List<dynamic>)> getPreconditions(
      Symbol methodName) {
    return _preconditions[methodName] ?? [];
  }

  static List<bool Function(dynamic)> getPostconditions(Symbol methodName) {
    return _postconditions[methodName] ?? [];
  }
}

// Contract enforcer using Dart mirrors and contract registry
class ContractEnforcer {
  static dynamic enforceContracts(
      Object instance, Symbol methodName, List positionalArgs) {
    var instanceMirror = reflect(instance);
    var classMirror = instanceMirror.type;

    var method = classMirror.instanceMembers[methodName];

    if (method == null) {
      throw Exception('Method not found: $methodName');
    }

    if (method.metadata.any((meta) => meta.reflectee is HasPreconditions)) {
      for (var precondition in ContractRegistry.getPreconditions(methodName)) {
        assert(precondition(positionalArgs),
            'Precondition failed for method: $methodName');
      }
    }

    var result = instanceMirror.invoke(methodName, positionalArgs).reflectee;

    if (method.metadata.any((meta) => meta.reflectee is HasPostconditions)) {
      for (var postcondition
          in ContractRegistry.getPostconditions(methodName)) {
        assert(postcondition(result),
            'Postcondition failed for method: $methodName');
      }
    }

    return result;
  }
}

// Proxy class to handle method invocations and contract checks
class ContractProxy {
  final Object _instance;

  ContractProxy(this._instance);

  dynamic invoke(Symbol methodName, List positionalArgs) {
    return ContractEnforcer.enforceContracts(
        _instance, methodName, positionalArgs);
  }
}

// Example class
class MyClass {
  int foo = 100;

  MyClass() {
    // Register precondition and postcondition at initialization
    ContractRegistry.registerPrecondition(#multiplyValueByPositive,
        (List<dynamic> arguments) => arguments.first > 0);
    ContractRegistry.registerPostcondition(
        #multiplyValueByPositive, (result) => result > 0);
  }

  @hasPostconditions
  @hasPreconditions
  int multiplyValueByPositive(int multiplier) {
    return foo * multiplier;
  }

}

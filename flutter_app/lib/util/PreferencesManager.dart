///
/// PreferencesManager
///
/// A utility class to make intracting with preferences easier and
/// to facilitate future internationalization

class PreferencesManager {
  PreferencesOptionList unitOfMeasureOptionList = PreferencesOptionList();
  PreferencesOptionList clockOptionList = PreferencesOptionList();

  PreferencesManager() {
    // Init the units of measure list
    unitOfMeasureOptionList.preferenceList
        .add(PreferenceOption(id: 0, name: 'Imperial'));
    unitOfMeasureOptionList.preferenceList
        .add(PreferenceOption(id: 1, name: 'Metric'));

    clockOptionList.preferenceList
        .add(PreferenceOption(id: 0, name: '12-Hr Clock'));
    clockOptionList.preferenceList
        .add(PreferenceOption(id: 1, name: '24-Hr Clock'));
  }

  // Given the Unit of Measure preference ID, return its name
  String getUnitOfMeasureName(int id) {
    String name = 'Not Found';

    // Ok this is a bit hacky because I am depending on the fact that all of
    // my preferences are Zero-based and the IDs just happen to match their
    // index location in the list
    name = unitOfMeasureOptionList.preferenceList[id].name;

    return name;
  }

  // Given the Clock Hours preference ID, return its name
  String getClockHoursName(int id) {
    String name = 'Not Found';

    // Ok this is a bit hacky because I am depending on the fact that all of
    // my preferences are Zero-based and the IDs just happen to match their
    // index location in the list
    name = clockOptionList.preferenceList[id].name;

    return name;
  }
}

/// This represents a single option for a preference setting.
class PreferenceOption {
  late int id;
  late String name;

  PreferenceOption({required this.id, required this.name}) {}
}

/// This is a list of preference options
class PreferencesOptionList {
  List<PreferenceOption> preferenceList = [];
}

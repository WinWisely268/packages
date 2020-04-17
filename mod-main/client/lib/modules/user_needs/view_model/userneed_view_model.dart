import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mod_main/core/core.dart';
import 'package:mod_main/modules/orgs/data/org_model.dart';
import 'package:mod_main/modules/user_needs/data/user_need_model.dart';
import 'package:mod_main/modules/user_needs/services/user_need_service.dart';
import 'package:mod_main/core/shared_services/dynamic_widget_service.dart';
import '../../orgs/service/orgs_service.dart';

class UserNeedsViewModel extends BaseModel {
  String _orgId;
  Org _org;
  List<List<UserNeed>> _userNeedsByGroup;
  DynamicWidgetService dwService = DynamicWidgetService();

  final orgService = Modular.get<OrgsService>();
  final userNeedService = Modular.get<UserNeedService>();

  get org => _org;
  get userNeedsByGroup => _userNeedsByGroup;

  Map<String, dynamic> _value = <String, dynamic>{};

  Map<String, dynamic> get value => _value;

  initializeData(String orgId) {
    setBuzy(true);

    _orgId = orgId;
    _org = orgService.getOrgById(orgId);
    _userNeedsByGroup = userNeedService.getGroupedUserNeedsByOrgId(orgId);

    // We need to track which option of the dropdown was selected
    _userNeedsByGroup.forEach((group) {
      if (group.length > 1) {
        String key = generateDropdownKey(group);
        this.dwService.selectedDropdownOptions[key] = '';
      }
    });

    this.buildWidgetList();

    setBuzy(false);
  }

  void selectNeed(String key, value, {bool deferNotify: false}) {
    _value[key] = value;
    print(_value);
    if (!deferNotify) {
      notifyListeners();
    }
  }

  String generateDropdownKey(List<UserNeed> userNeeds) {
    String key = '';
    userNeeds.forEach((userNeed) => key += '|' + userNeed.id);

    // Remove the | off the font
    return key.substring(1);
  }

  void navigateNext() {
    showActionDialogBox(
      onPressedNo: () {
        Modular.to.pushNamed('/account/signup');
      },
      onPressedYes: () {
        Modular.to.pop();
        Modular.to.pushNamed(
            Modular.get<Paths>().supportRoles.replaceAll(':id', _orgId));
      },
      title: "Support Role",
      description:
          "If we cannot satisfy your chosen conditions, would you consider providing a support role to those willing to go on strike ?",
    );
  }

  List<Widget> buildWidgetList() {
    int questionCount = 1;
    const SizedBox spacer = SizedBox(height: 8.0);

    List<Widget> viewWidgetList = [];

    this.userNeedsByGroup.forEach((userNeedGroup) {
      if (userNeedGroup.length > 1) {
        Map<String, String> data = {};
        userNeedGroup
            .forEach((userNeed) => data[userNeed.description] = userNeed.id);

        String key = generateDropdownKey(userNeedGroup);
        DynamicDropdownButton ddb = DynamicDropdownButton(
            data: data,
            selectedOption: this.dwService.selectedDropdownOptions[key],
            callbackInjection: (data, selected) {
              data.forEach((key, value) {
                if (key == selected) {
                  this.selectNeed(value, true, deferNotify: true);
                } else {
                  this.selectNeed(value, false, deferNotify: true);
                }
              });
              notifyListeners();
            });

        viewWidgetList.add(ddb);
      } else if (userNeedGroup.first.isTextBox == "yes") {
        // If there is only 1 and it's a textbox

      } else {
        // If there is only 1 and it is NOT a textbox

        UserNeed _userNeed = userNeedGroup.first;

        viewWidgetList.add(CheckboxListTile(
          title:
              Text((questionCount++).toString() + '. ' + _userNeed.description),
          value: this.value[_userNeed.id] ?? false,
          onChanged: (bool value) {
            this.selectNeed(_userNeed.id, value);
          },
          //secondary: const Icon(FontAwesomeIcons.peopleCarry),
        ));
      }

      // Add the spacer
      viewWidgetList.add(spacer);
    });

    return viewWidgetList;
  }
}

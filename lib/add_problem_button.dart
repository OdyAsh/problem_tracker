// ignore_for_file: sort_child_properties_last

import 'package:cf_tracker/user_sheets_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'motion_toast.dart' as toast_file;

import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';
import 'user_sheets_api.dart';
import 'globals.dart' as globals;

/// Tag-value used for the add problem-code popup button.
const String _heroAddProblem = 'add-problem-code-hero';

/// {@template add_problem_code_button}
/// Button to add a new [Problem Code].
///
/// Opens a [HeroDialogRoute] of [_AddProblemCodePopupCard].
///
/// Uses a [Hero] with tag [_heroAddProblem].
/// {@endtemplate}
class AddProblemCodeButton extends StatefulWidget {
    /// {@macro add_problem_code_button}
    const AddProblemCodeButton({Key? key}) : super(key: key);

  @override
  State<AddProblemCodeButton> createState() => _AddProblemCodeButtonState();
}

class _AddProblemCodeButtonState extends State<AddProblemCodeButton> {
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(32.0), // makes the button not extremely at the bottom-right of the app's UI
            child: MouseRegion( // to change mouse from couser to pointer when hovering, source: https://www.youtube.com/watch?v=1oF3pI5umck
                cursor: SystemMouseCursors.click, // <---||
                child: GestureDetector(
                onTap: () {
                    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                        return const _AddProblemCodePopupCard();
                    }));
                },
                child: Hero(
                    tag: _heroAddProblem,
                    createRectTween: (begin, end) { // the animation done from this button to _AddProblemCodePopupCart widget (which is displayed on a new page due to Navigator.of())
                        return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Container(
                        constraints: const BoxConstraints(
                            minHeight: 50, 
                            minWidth: 50
                        ),
                        child: Material( // the actual button UI
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            child: const Icon(
                                Icons.add_chart,
                                size: 35,
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}

/// {@template add_todo_popup_card}
/// Popup card to add a new [Problem Code]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddProblem].
/// {@endtemplate}
class _AddProblemCodePopupCard extends StatefulWidget {
    /// {@macro add_problem_code_popup_card}
    const _AddProblemCodePopupCard({Key? key}) : super(key: key);

  @override
  State<_AddProblemCodePopupCard> createState() => _AddProblemCodePopupCardState();
}

String? _platform; // the online platform chosen (codeforces, cses, etc) (Note: if _platform is null, then it is treated as "CF") (Note 2: String is outside the class to retain its value when card opens again)

class _AddProblemCodePopupCardState extends State<_AddProblemCodePopupCard> {
    final _codeOrCredentialsTextController = TextEditingController();  // for fetching problem code from top text field
    final _typeOrSheetIdTextController = TextEditingController();  // for fetching problem type from bottom text field or Google sheets ID
    final _workSheetTextController = TextEditingController();  // for fetching current worksheet's name
    final _userNameTextController = TextEditingController(); // for fetching user's codeforces username
    String googleSheetsID = UserSheetsApi.getSheetId;
    bool _sheetAvailable = (UserSheetsApi.getSheetId != '');
    String chosenWorksheet = "";

    @override
    Widget build(BuildContext context) {
        return Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: Hero(
                    tag: _heroAddProblem,
                    createRectTween: (begin, end) {
                        return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Material( // the actual rectangular card that appears in the UI
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        child: SingleChildScrollView( // it isn't used for scrolling here. Rather it is used to avoid the RenderFlex overflow that occurs for milliseconds when opening up this card
                            child: Padding(
                                padding: const EdgeInsets.all(16.0), // padding between all child elements and parent container (card)
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        TextField( // text fields look source: https://www.javatpoint.com/flutter-textfield
                                            controller: _codeOrCredentialsTextController,
                                            decoration: InputDecoration(
                                                border: const OutlineInputBorder(),  
                                                labelText: (!_sheetAvailable) ? 'Credentials' : 'Problem Code',  
                                                hintText: (!_sheetAvailable) ? 'JSON of service account' : 'found in codeforces url, ex: 713',  
                                            ),
                                        ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.4,
                                        ),
                                        if (_platform is! String || _platform == "CF") ...[
                                            TextField(
                                                controller: _typeOrSheetIdTextController,
                                                decoration: InputDecoration(
                                                    border: const OutlineInputBorder(),  
                                                    labelText: (!_sheetAvailable) ? 'Google Sheets ID' : 'Problem Level',  
                                                    hintText: (!_sheetAvailable) ? 'string between d/ and /edit' : 'ex: A,B,C,...',  
                                                ),
                                            cursorColor: Colors.blue,
                                            maxLines: 1,
                                            ),
                                            const Divider(
                                                color: Colors.white,
                                                thickness: 0.4,
                                            ),
                                        ],
                                        if (_sheetAvailable) ... [
                                            DropdownButton( // to-do: fix "A RenderFlex overflowed by 49 pixels on the right."
                                                hint: const Text("Default: CF"),
                                                value: _platform,
                                                items: const [
                                                    DropdownMenuItem(value: "CF", child: Text("CF")),
                                                    DropdownMenuItem(value: "CSES", child: Text("CSES")),
                                                ], 
                                                onChanged: (String? selectedPlatform) { 
                                                    if (selectedPlatform is String) {
                                                        setState(() {
                                                        _platform = selectedPlatform;
                                                        });
                                                    }
                                                },
                                            ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.4,
                                        ),
                                        ] ,
                                        
                                        if (!_sheetAvailable) ...[
                                            TextField(
                                                controller: _workSheetTextController,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),  
                                                    labelText: 'Worksheet',  
                                                    hintText: 'Name of tab at the bottom',  
                                                ),
                                                cursorColor: Colors.blue,
                                                maxLines: 1,
                                            ),
                                            const Divider(
                                                color: Colors.white,
                                                thickness: 0.4,
                                            ),
                                            TextField(
                                                controller: _userNameTextController,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),  
                                                    labelText: 'CF Username',  
                                                    hintText: 'ex: OdyAsh',  
                                                ),
                                                cursorColor: Colors.blue,
                                                maxLines: 1,
                                            ),
                                            const Divider(
                                                color: Colors.white,
                                                thickness: 0.4,
                                            ),
                                        ],
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Flexible(
                                                flex: 1,
                                                child: ElevatedButton(
                                                    child: (!_sheetAvailable) ? const Text("Submit Info") : const Text("Change Info"),
                                                    style: ElevatedButton.styleFrom(
                                                        primary: Colors.blueGrey,
                                                    ),
                                                    onPressed: () async {
                                                        if (!_sheetAvailable) {
                                                            googleSheetsID = _typeOrSheetIdTextController.text;
                                                            String creds = _codeOrCredentialsTextController.text;
                                                            String wsName = _workSheetTextController.text;
                                                            String cfName = _userNameTextController.text;
                                                            await UserSheetsApi.initFromUI(creds, googleSheetsID, wsName, cfName);
                                                            _codeOrCredentialsTextController.text = '';
                                                            _typeOrSheetIdTextController.text = '';
                                                            setState(() {
                                                              _sheetAvailable = true;
                                                              globals.worksheetNames = UserSheetsApi.getWorksheetNames;
                                                              toast_file.displayResponsiveMotionToast(context, "Welcome $cfName!!!", 'You will remain signed in until you press "change info"');
                                                            });
                                                        } else {
                                                            setState(() {
                                                              _sheetAvailable = false; // to-do: change logic so that if the user clicks out of card without changing info, it reverts back and _sheetAvailable is true again
                                                            });
                                                        }
                                                    },
                                                ),
                                              ),
                                              if (_sheetAvailable) Flexible(
                                                flex: 1,
                                                child: ElevatedButton(
                                                    child: const Text('Track'),
                                                    onPressed: () async {
                                                        // logic to fetch problem name
                                                        String? code;
                                                        String? level; // to-do: make them retain their values when operning card again (putting these variables outside the class doesn't work)
                                                        if (_platform is! String || _platform == "CF") {
                                                            code = _codeOrCredentialsTextController.text;
                                                            level = _typeOrSheetIdTextController.text;
                                                            globals.problemLink = "https://codeforces.com/problemset/problem/$code/$level";
                                                        }
                                                        else if (_platform == "CSES") {
                                                            code = _codeOrCredentialsTextController.text;
                                                            globals.problemLink = "https://cses.fi/problemset/task/$code";
                                                        }
                                                        List<String> newProb = await getProblemName(link: globals.problemLink, platform: _platform);
                                                        if (newProb[0] == "-1" || newProb[0] == "-2") {
                                                            return showDialog(
                                                                    context: context, 
                                                                    builder: (BuildContext context) => AlertDialog(
                                                                        title: const Text('Error'),
                                                                        content:  Text(
                                                                            newProb[0] == "-1" ?
                                                                            "No internet connection"
                                                                            : "Problem not found or you're in a live contest"
                                                                            ),
                                                                        actions: [
                                                                            TextButton(
                                                                                onPressed: () { 
                                                                                    Navigator.pop(context, 'OK');
                                                                                    Navigator.pop(context);
                                                                                    globals.problemNameCard.value = true;
                                                                                },
                                                                                child: const Text('set problem name as "..."'),
                                                                            ),
                                                                        ],
                                                                    )
                                                                );
                                                        }
                                                        else{
                                                            globals.problemNameCard.value = true;
                                                            globals.problemName = newProb[0];
                                                            globals.problemDiv = newProb[1]; // if platform == CSES, problemDiv is actually the problem category (dp, etc)
                                                            globals.problemCode = code!;
                                                            globals.problemLevel = level;
                                                            globals.platform = _platform;
                                                            Navigator.pop(context); // closes card. to-do: fix warning: "Do not use BuildContexts across async gaps."
                                                        }
                                                    },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}

Future<List<String>> getProblemName({required String link, required String? platform}) async{
    var response = await http.get(Uri.parse(link));
    if(response.statusCode != 200){
        return ["-1","-1"];
    }
    String htmlToParse = response.body;
    RegExp? regex1;
    RegExp? regex2;
    if (platform is! String || platform == "CF") {
            regex1 = RegExp(r'<div class="title">([^<]*)</div>'); // source: https://stackoverflow.com/questions/3467369/regex-to-grab-an-entire-div-with-a-specific-id
        if (!regex1.hasMatch(htmlToParse)){
            return ["-2","-2"];
        }
        //regex2 = RegExp(r'(Codeforces.+?(?=\)</a>))');
        regex2 = RegExp(r'(<a style=.+?(?=href="/contest/).+</a>)'); // logic: search for <a style=, then keep matching until you find href="/contest/, when this is found, match it and keep matching (using .+) until </a>, source: https://stackoverflow.com/questions/7124778/how-can-i-match-anything-up-until-this-sequence-of-characters-in-a-regular-exp
        if (!regex2.hasMatch(htmlToParse)){
            return ["-3","-3"];
        }
        String probName = regex1.firstMatch(htmlToParse)!.groups([1])[0]!;
        String division = regex2.firstMatch(htmlToParse)!.groups([1])[0]!;
        int divLoc1 = division.indexOf('Div. ');
        int divLoc2 = division.indexOf('Round ');
        if (divLoc1 != -1) {
            division = "D${division[divLoc1+'div. '.length]}";
        } else if (divLoc2 != -1) {
            division = "G${division.substring(divLoc2+'Round '.length, division.indexOf('</a>'))}"; // arguments of substring in dart: [startingIndex, endingIndex)
        } else {
            division = division.substring(division.indexOf('>'), division.indexOf('</a>'));
        }
        return [probName, division];
    }
    if (platform == "CSES") {
        regex1 = RegExp(r'<h1>([^<]*)</h1>');
        if (!regex1.hasMatch(htmlToParse)){
            return ["-2","-2"];
        }
        regex2 = RegExp(r'<h4>([^<]*)</h4>');
        if (!regex2.hasMatch(htmlToParse)){
            return ["-3","-3"];
        }
        String probNameCSES = regex1.firstMatch(htmlToParse)!.groups([1])[0]!;
        String category = regex2.firstMatch(htmlToParse)!.groups([1])[0]!;
        if (category.contains("Intro")) {
          category = "INT";
        } else if (category.contains("Sort")) {
            category = "SRT";
        } else if (category.contains("Dyn")) {
            category = "DP";
        } else if (category.contains("Gra")) {
            category = "GPH";
        } else if (category.contains("Ran")) {
            category = "RNG";
        } else if (category.contains("Tree")) {
            category = "TRE";
        } else if (category.contains("Math")) {
            category = "MTH";
        } else if (category.contains("Str")) {
            category = "STR";
        } else if (category.contains("Geo")) {
            category = "GEO";
        } else if (category.contains("Adv")) {
            category = "ADV";
        } else if (category.contains("Add")) {
            category = "ADD";
        }
        return [probNameCSES, category];
    }
    else {
        return ['-5', '-5'];
    }
}
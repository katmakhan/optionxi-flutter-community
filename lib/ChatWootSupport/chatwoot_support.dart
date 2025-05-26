// import 'package:flutter/material.dart';
// import 'package:chatwoot_client_sdk/chatwoot_client_sdk.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ChatwootWidget extends StatelessWidget {
//   const ChatwootWidget({Key? key}) : super(key: key);

//   void _showChatwootDialog(BuildContext context, User user) {
//     ChatwootChatDialog.show(
//       context,
//       baseUrl: "https://chat.optionxi.com",
//       inboxIdentifier: "C1RPxCnBSc2vHtKpFbbYG25n",
//       title: "Chatwoot Support",
//       user: ChatwootUser(
//         identifier: user.email ?? user.uid,
//         name: user.displayName ?? "Anonymous",
//         email: user.email ?? "anaonymous@flutter.com",
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user == null) {
//       return Center(child: Text("Not logged in"));
//     }

//     return ChatwootChat(
//       baseUrl: "https://chat.optionxi.com",
//       // inboxIdentifier: "C1RPxCnBSc2vHtKpFbbYG25n",
//       inboxIdentifier: '7xX321vmYjyjSueezeenKgqr',
//       // user: ChatwootUser(
//       //   identifier: user.email ?? user.uid,
//       //   name: user.displayName ?? "Anonymous",
//       //   email: user.email ?? "anonymous@optionxi.com",
//       // ),
//       user: ChatwootUser(
//         identifier: "somethinguniquie",
//         name: "Anonymous",
//         email: "anonymous@optionxi.com",
//       ),
//       appBar: AppBar(
//         title: const Text(
//           "Chatwoot",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         leading: InkWell(
//           onTap: () {
//             // _showChatwootDialog(context, user);
//             Navigator.pop(context);
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Image.asset("assets/images/option_xi.png"),
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),
//       onWelcome: () => print("Welcome event received"),
//       onPing: () => print("Ping event received"),
//       onConfirmedSubscription: () => print("Confirmation event received"),
//       onMessageDelivered: (_) => print("Message delivered"),
//       onMessageSent: (_) => print("Message sent"),
//       onConversationIsOffline: () => print("Conversation is offline"),
//       onConversationIsOnline: () => print("Conversation is online"),
//       onConversationStoppedTyping: () => print("Stopped typing"),
//       onConversationStartedTyping: () => print("Started typing"),
//     );
//   }
// }

// Copyright 2024-2026 ProntoGUI, LLC
// ProntoGUI™ is a trademark of ProntoGUI, LLC
// Licensed under the BSD 3-Clause License. See the LICENSE file.

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'widgets/server_field.dart';
import 'inherited_comm.dart';
import 'package:dartlib/dartlib.dart' as pg;
import 'window/window_management.dart';

class WaitingForServerView extends StatefulWidget {
  const WaitingForServerView({super.key, required this.operatingView});

  final Widget operatingView;

  @override
  State<WaitingForServerView> createState() => _WaitingForServerViewState();
}

class _WaitingForServerViewState extends State<WaitingForServerView> {
  late TextEditingController _titleController;
  int _rebuildKey = 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: WindowManagement.instance.settings.title,
    );
    WindowManagement.instance.notifyOurWindowReopened.addListener(_onWindowReopened);
  }

  @override
  void dispose() {
    WindowManagement.instance.notifyOurWindowReopened.removeListener(_onWindowReopened);
    _titleController.dispose();
    super.dispose();
  }

  void _onWindowReopened() {
    // Update the title controller with the new (reset) settings
    final settings = WindowManagement.instance.settings;
    _titleController.text = settings.title;

    // Also reset the comm server settings to match the reset window settings
    final comm = InheritedCommClient.of(context);
    comm.serverAddress = settings.host;
    comm.serverPort = settings.port;

    // Increment rebuild key to force ServerField to recreate with new values
    _rebuildKey++;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var comm = InheritedCommClient.of(context);

    switch (comm.state) {
      case pg.CommState.inactive:
        return _buildInactiveMessage(context, comm);
      case pg.CommState.active:
        return widget.operatingView;
      case pg.CommState.connecting:
        return _buildBlankScreen(context);
      case pg.CommState.connectingWait:
        return _buildConnectingWaitMessage(context, comm);
      case pg.CommState.reestablishmentDelay:
        return _buildReestablishmentDelayMessage(context, comm);
    }
  }

  Widget _buildBlankScreen(BuildContext context) {
    return const Scaffold(body: SizedBox());
  }

  Widget _openButton(pg.CommClientCtl pgcomm) {
    return OutlinedButton.icon(
      onPressed: () {
        pgcomm.open();
      },
      label: const Text('Open'),
      icon: const Icon(
        Icons.link_outlined,
//        color: Colors.black87,
        size: 30.0,
      ),
    );
  }

  Widget _closeButton(pg.CommClientCtl pgcomm) {
    return OutlinedButton.icon(
      onPressed: () {
        pgcomm.close();
      },
      label: const Text('Close'),
      icon: const Icon(
        Icons.link_off_outlined,
//        color: Colors.black87,
        size: 30.0,
      ),
    );
  }

  Widget _buildInactiveMessage(BuildContext context, pg.CommClientCtl comm) {
    return _buildCommon(
        comm,
        SizedBox.fromSize(size: Size.fromHeight(50), child: Align(alignment: AlignmentGeometry.center, child: const Text('Communication closed.'))),
        Column(
          children: [
            SizedBox(
              height: 50,
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Window title'),
                ),
                onChanged: (value) async {
                  final wm = WindowManagement.instance;
                  wm.settings.title = value;
                  wm.saveSettings();
                  await windowManager.setTitle(value);
                  await wm.broadcastTitleChange(wm.settings.windowKey);
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
                height: 50,
                child: ServerField(
                  key: ValueKey(_rebuildKey),
                  serverAddress: comm.serverAddress,
                  serverPort: comm.serverPort,
                  onChange: (addr, port) {
                    comm.serverAddress = addr;
                    comm.serverPort = port;
                    final wm = WindowManagement.instance;
                    wm.settings.host = addr;
                    wm.settings.port = port;
                    wm.saveSettings();
                  },
                )),
          ],
        ),
        true);
  }

  Widget _buildConnectingWaitMessage(
      BuildContext context, pg.CommClientCtl pgcomm) {
    return _buildCommon(
        pgcomm,
        Row(
          children: [
            Text(
                'Waiting for connection to server ${pgcomm.serverEndpointDescription()}'),
            TextButton(
                onPressed: () => pgcomm.tryConnectionAgain(),
                child: const Text('Try Again')),
          ],
        ),
        const LinearProgressIndicator(),
        false);
  }

  Widget _buildReestablishmentDelayMessage(
      BuildContext context, pg.CommClientCtl pgcomm) {
    return _buildCommon(
      pgcomm,
      Row(
        children: [
          Text(
              'Reestablishing connection to server ${pgcomm.serverEndpointDescription()}'),
          TextButton(
              onPressed: () => pgcomm.tryConnectionAgain(),
              child: const Text('Try Again')),
        ],
      ),
      LinearProgressIndicator(
        value: pgcomm.reestablishmentWaitProgress,
      ),
      false,
    );
  }

  Widget _buildCommon(
      pg.CommClientCtl pgcomm, Widget widget1, Widget? widget2, bool openMode) {
    return Scaffold(
        body: Center(
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            const Spacer(),
            Icon(
              openMode ? Icons.link_off_outlined : Icons.link_outlined,
              //color: openMode ? Colors.black87 : Colors.green,
              size: 60.0,
            ),
            widget1,
            widget2 ??
                const SizedBox(
                  height: 30,
                ),
            const SizedBox(
              height: 30,
            ),
            openMode ? _openButton(pgcomm) : _closeButton(pgcomm),
            const Spacer(),
          ],
        ),
      ),
    ));
  }
}

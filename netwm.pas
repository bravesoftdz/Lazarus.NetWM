{ This unit provides a general interface to communicate with
  X Window Managers such as Compiz, KWin, or Xfwm

  For more informationSee the NetWM protocol:
  http://standards.freedesktop.org/wm-spec/1.3/index.html

  Copyleft by Anthony Walter <sysrpl@gmail.com>
  October 2015 }

unit NetWM;

{$mode delphi}

interface

uses
   X, XLib;

{ WindowManager is a static type implementing SOME of the
  NetWM protocol. It is a starter type. }

type
  WindowManager = record
  private
    class function SetState(Window: TWindow; State: string;
      Active: Boolean; Toggle: Boolean = False): Boolean; static;
  public
    { Show or hide all the windows on your current workspace }
    class function ShowDesktop(Show: Boolean): Boolean; static;
    { Switch workspace, bring a window to the foreground, and give it input }
    class function Activate(Window: TWindow): Boolean; static;
    { Stick a window to the same place in all workspaces }
    class function Sticky(Window: TWindow; Stick: Boolean): Boolean; static;
    { Roll a window up to its title bar }
    class function Shaded(Window: TWindow; Shade: Boolean): Boolean; static;
    { Toggle window taking up the entire screen with no decorations }
    class function Fullscreen(Window: TWindow): Boolean; static;
    { Make window stay above all other windows, even when not active }
    class function Above(Window: TWindow; Topmost: Boolean): Boolean; static;
    { Asks the window manage to bring attention to the window }
    class function Attention(Window: TWindow): Boolean; static;
  end;

{ For Gtk to get a TWindow from an LCLTControl
  you may use this code similar to this:

  function XWindow(Control: TControl): TWindow;
  var
    P: TWinControl;
    W: PGdkWindow;
  begin
    Result := 0;
    if Control = nil then
      Exit;
    if Control is TWinControl then
      P := Control as TWinControl
    else
      P := Control.Parent;
    if P = nil then
      Exit;
    while P.Parent <> nil do
      P := P.Parent;
    if P <> nil then
    begin
      W := GTK_WIDGET(PGtkWidget(P.Handle)).window;
      Result := gdk_x11_drawable_get_xid(W);
    end;
  end;  }

implementation

function SendMessage(Display: PDisplay; Window: TWindow;
  Msg: PChar; Param0: LongWord = 0; Param1: LongWord = 0;
  Param2: LongWord = 0; Param3: LongWord = 0; Param4: LongWord = 0): Boolean; overload;
var
  Event: TXEvent;
  Mask: LongWord;
begin
  Mask := SubstructureRedirectMask or SubstructureNotifyMask;
  Event.xclient._type := ClientMessage;
  Event.xclient.serial := 0;
  Event.xclient.send_event := 1;
  Event.xclient.message_type := XInternAtom(Display, Msg, False);
  Event.xclient.window := Window;
  Event.xclient.format := 32;
  Event.xclient.data.l[0] := Param0;
  Event.xclient.data.l[1] := Param1;
  Event.xclient.data.l[2] := Param2;
  Event.xclient.data.l[3] := Param3;
  Event.xclient.data.l[4] := Param4;
  Result := XSendEvent(Display, DefaultRootWindow(Display), False, Mask, @Event) <> 0;
end;

function SendMessage(Msg: PChar; Param: LongWord): Boolean; overload;
var
  Display: PDisplay;
begin
  Display := XOpenDisplay(nil);
  Result := SendMessage(Display, DefaultRootWindow(Display), Msg, Param);
  XCloseDisplay(Display);
end;

{ WindowManager }

class function WindowManager.ShowDesktop(Show: Boolean): Boolean;
const
  BoolFlags: array[Boolean] of LongWord = (0, 1);
begin
  Result := SendMessage('_NET_SHOWING_DESKTOP', BoolFlags[Show]);
end;

class function WindowManager.Activate(Window: TWindow): Boolean;
var
  Display: PDisplay;
begin
  if Window = 0 then
    Exit;
  Display := XOpenDisplay(nil);
  Result := SendMessage(Display, Window, '_NET_ACTIVE_WINDOW');
  XMapRaised(Display, Window);
  XCloseDisplay(Display);
end;

class function WindowManager.SetState(Window: TWindow; State: string; Active: Boolean;
  Toggle: Boolean = False): Boolean;
const
  _NET_WM_STATE_REMOVE       = 0;    { remove/unset property }
  _NET_WM_STATE_ADD          = 1;    { add/set property }
  _NET_WM_STATE_TOGGLE       = 2;    { toggle property }
  StateFlags: array[Boolean] of LongWord = (_NET_WM_STATE_REMOVE, _NET_WM_STATE_ADD);
var
  Display: PDisplay;
  S: string;
  P0, P1: LongWord;
begin
  if Window = 0 then
    Exit;
  Display := XOpenDisplay(nil);
  P0 := StateFlags[Active];
  if Toggle then
    P0 := _NET_WM_STATE_TOGGLE;
  S := '_NET_WM_STATE_' + State;
  P1 := XInternAtom(Display, PChar(S), False);
  Result := SendMessage(Display, Window, '_NET_WM_STATE', P0, P1);
  XCloseDisplay(Display);
end;

class function WindowManager.Sticky(Window: TWindow; Stick: Boolean): Boolean;
begin
  Result := SetState(Window, 'STICKY', Stick);
end;

class function WindowManager.Shaded(Window: TWindow; Shade: Boolean): Boolean;
begin
  Result := SetState(Window, 'SHADED', Shade);
end;

class function WindowManager.Fullscreen(Window: TWindow): Boolean;
begin
  Result := SetState(Window, 'FULLSCREEN', False, True);
end;

class function WindowManager.Above(Window: TWindow; Topmost: Boolean): Boolean;
begin
  Result := SetState(Window, 'ABOVE', Topmost);
end;

class function WindowManager.Attention(Window: TWindow): Boolean;
begin
  Result := SetState(Window, 'DEMANDS_ATTENTION', True);
end;

end.


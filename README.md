# Lazarus.NetWM

Copyleft by Anthony Walter <sysrpl@gmail.com> October 2015
  
This is the a repository for a Lazarus unit to make some window management functions on X easier.

The following functionality is currently supported:

* Activating your applciation, bringing it to the foreground with input focus
* Sticking windows to multiple workspaces
* Calling attention to your application (varies by window manager)
* Going into and out of fullscreen mode
* Shading your window
* Making your window topmost

Functionality left out:

* Defining and switching workspaces
* Querying desktops areas and redefining desktop positions and sizes
* Window and desktop enumerating
* Closing, moving, resizing windows other than your own
* Hiding windows from the taskbar and application switcher
* Turning window animations on and off
* Switching window types

For more information about NetWM protocol see:

http://standards.freedesktop.org/wm-spec/1.3/index.html

Note, most of the function require a X window id. To get an X window id on Gtk you can use code similar to the the following:

```
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
end;
```

#tag DesktopWindow
Begin DesktopWindow formBandSettings
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   False
   HasMinimizeButton=   False
   HasTitleBar     =   True
   Height          =   370
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   370
   MaximumWidth    =   360
   MenuBar         =   ""
   MenuBarVisible  =   False
   MinimumHeight   =   370
   MinimumWidth    =   360
   Resizeable      =   False
   Title           =   "Band Settings"
   Type            =   0
   Visible         =   True
   Width           =   360
   Begin DesktopLabel InstructionsLabel
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Multiline       =   False
      Scope           =   0
      Selectable      =   False
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   "Enter the frequency for each band in MHz."
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   16
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   320
   End
   Begin DesktopListBox BandList
      AllowAutoDeactivate=   True
      AllowAutoHideScrollbars=   True
      AllowExpandableRows=   False
      AllowFocusRing  =   True
      AllowResizableColumns=   False
      AllowRowDragging=   False
      AllowRowReordering=   False
      Bold            =   False
      ColumnCount     =   2
      ColumnWidths    =   "35%,65%"
      DefaultRowHeight=   -1
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      GridLineStyle   =   1
      HasBorder       =   True
      HasHeader       =   True
      HeaderHeight    =   0
      Height          =   268
      Index           =   -2147483648
      InitialValue    =   ""
      Italic          =   False
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      RequiresSelection=   False
      RowSelectionType=   0
      Scope           =   0
      TabIndex        =   1
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   "Double-click a frequency to edit it."
      Top             =   44
      Transparent     =   False
      Visible         =   True
      Width           =   320
      _ScrollOffset   =   0
      _ScrollWidth    =   -1
   End
   Begin DesktopButton SaveButton
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   False
      Caption         =   "Save"
      Default         =   True
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   172
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   2
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   330
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   80
   End
   Begin DesktopButton CancelButton
      AllowAutoDeactivate=   True
      Bold            =   False
      Cancel          =   True
      Caption         =   "Cancel"
      Default         =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   20
      Index           =   -2147483648
      Italic          =   False
      Left            =   260
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      MacButtonStyle  =   0
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   330
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   80
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  BandList.HeaderAt(0) = "Band"
		  BandList.HeaderAt(1) = "Frequency (MHz)"
		  BandList.ColumnTypeAt(1) = DesktopListBox.CellTypes.TextField

		  AddBand("80 m", Preferences.Band80Frequency)
		  AddBand("60 m", Preferences.Band60Frequency)
		  AddBand("40 m", Preferences.Band40Frequency)
		  AddBand("30 m", Preferences.Band30Frequency)
		  AddBand("20 m", Preferences.Band20Frequency)
		  AddBand("17 m", Preferences.Band17Frequency)
		  AddBand("15 m", Preferences.Band15Frequency)
		  AddBand("12 m", Preferences.Band12Frequency)
		  AddBand("10 m", Preferences.Band10Frequency)
		  AddBand("6 m", Preferences.Band6Frequency)
		End Sub
	#tag EndEvent

	#tag Method, Flags = &h21
		Private Sub AddBand(bandName As String, frequencyKHz As Integer)
		  BandList.AddRow(bandName, Format(frequencyKHz / 1000.0, "0.000"))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FrequencyAt(row As Integer) As Integer
		  Var frequencyMHz As Double = BandList.CellTextAt(row, 1).ToDouble
		  Var frequencyKHz As Integer = Round(frequencyMHz * 1000.0)

		  If frequencyKHz <= 0 Or frequencyKHz > 60000 Then
		    Raise New InvalidArgumentException
		  End If

		  Return frequencyKHz
		End Function
	#tag EndMethod
#tag EndWindowCode

#tag Events SaveButton
	#tag Event
		Sub Pressed()
		  Var frequencies(9) As Integer

		  Try
		    For row As Integer = 0 To 9
		      frequencies(row) = FrequencyAt(row)
		    Next row
		  Catch error As RuntimeException
		    MessageBox("Enter a valid frequency greater than 0 and no more than 60 MHz for every band.")
		    Return
		  End Try

		  Preferences.Band80Frequency = frequencies(0)
		  Preferences.Band60Frequency = frequencies(1)
		  Preferences.Band40Frequency = frequencies(2)
		  Preferences.Band30Frequency = frequencies(3)
		  Preferences.Band20Frequency = frequencies(4)
		  Preferences.Band17Frequency = frequencies(5)
		  Preferences.Band15Frequency = frequencies(6)
		  Preferences.Band12Frequency = frequencies(7)
		  Preferences.Band10Frequency = frequencies(8)
		  Preferences.Band6Frequency = frequencies(9)

		  If Not Preferences.Save Then
		    MessageBox("The band settings could not be saved.")
		    Return
		  End If

		  Close
		End Sub
	#tag EndEvent
#tag EndEvents

#tag Events CancelButton
	#tag Event
		Sub Pressed()
		  Close
		End Sub
	#tag EndEvent
#tag EndEvents

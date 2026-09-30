#tag Class
Protected Class App
Inherits DesktopApplication
	#tag Event
		Sub Opening()
		  
		  app.AllowAutoQuit = True
		  
		  
		  ModernPreferences.Initialise("SteppirController")
		  
		  if not Preferences.Load() then
		    Preferences.SteppirIP = ""
		    Preferences.SteppirPort = ""
		    Preferences.SteppirSerialPort = ""
		    Preferences.SteppirSerialBaud = ""
		    Preferences.SteppirComType = 0
		    Preferences.Top = 50
		    Preferences.Left = 1
		  end if
		  
		  if Preferences.FlexRadio = nil then
		    Preferences.FlexRadio = "0.0.0.0"
		  end if

		  // Band button frequencies are stored in kHz.
		  // Apply defaults individually so older preference files gain new keys.
		  If Preferences.Band80Frequency = Nil Then Preferences.Band80Frequency = 3650
		  If Preferences.Band60Frequency = Nil Then Preferences.Band60Frequency = 5125
		  If Preferences.Band40Frequency = Nil Then Preferences.Band40Frequency = 7150
		  If Preferences.Band30Frequency = Nil Then Preferences.Band30Frequency = 10125
		  If Preferences.Band20Frequency = Nil Then Preferences.Band20Frequency = 14200
		  If Preferences.Band17Frequency = Nil Then Preferences.Band17Frequency = 18125
		  If Preferences.Band15Frequency = Nil Then Preferences.Band15Frequency = 21200
		  If Preferences.Band12Frequency = Nil Then Preferences.Band12Frequency = 24915
		  If Preferences.Band10Frequency = Nil Then Preferences.Band10Frequency = 28300
		  If Preferences.Band6Frequency = Nil Then Preferences.Band6Frequency = 50300
		  '
		  'if Preferences.cAntenna = nil then
		  'Preferences.cAntenna = ""
		  'end if
		  
		  if not Preferences.Save() then
		    msgbox "Error Saving Preferences!"
		  end if
		  
		  
		End Sub
	#tag EndEvent


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=false
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=false
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=false
			Group="Position"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoQuit"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowHiDPI"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BugVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Copyright"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Description"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastWindowIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MajorVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MinorVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="NonReleaseVersion"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="RegionCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="StageCode"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Version"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="string"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_CurrentEventTime"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass

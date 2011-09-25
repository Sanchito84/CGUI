/*
Class: CChoiceControl
This class implements DropDownList, ComboBox and ListBox controls.

This control extends <CControl>. All basic properties and functions are implemented and documented in this class.
*/
Class CChoiceControl Extends CControl ;This class is a ComboBox, ListBox and DropDownList
{
	__New(Name, Options, Text, GUINum, Type)
	{
		Base.__New(Name, Options, Text, GUINum)
		this.Type := Type
		if(Type = "Combobox")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100, Simple : 0x1})
		else if(Type = "DropDownList")
			this._.Insert("ControlStyles", {LowerCase : 0x400, Uppercase : 0x2000, Sort : 0x100})
		else if(Type = "ListBox")
			this._.Insert("ControlStyles", {Multi : 0x800, ReadOnly : 0x4000, Sort : 0x2, ToggleSelection : 0x8})
		this._.Insert("Events", ["SelectionChanged"])
		if(Type = "ListBox")
			this._.Insert("Messages", {5 : "KillFocus", 4 : "SetFocus" }) ;Used for automatically registering message callbacks		
		else if(Type = "ComboBox" || Type = "DropDownList")
			this._.Insert("Messages", {4 : "KillFocus", 3 : "SetFocus" }) ;Used for automatically registering message callbacks
	}
	PostCreate()
	{
		Base.PostCreate()
		this._.Items := new this.CItems(this.GUINum, this.hwnd)
		Content := this.Content
		Loop, Parse, Content, |
			this._.Items.Insert(new this.CItems.CItem(A_Index, this.GUINum, this.hwnd))
		this._.PreviouslySelectedItem := this.SelectedItem
	}
	/*
	Variable: SelectedItem
	The text of the selected item.
	
	Variable: SelectedIndex
	The index of the selected item.
	
	Variable: Items
	An array containing all items. See <CChoiceControl.CItems>.
	*/
	__Get(Name, Params*)
    {
		;~ global CGUI
		if(Name != "GUINum" && !CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			if(Name = "SelectedItem")
			{
				SendMessage, 0x147, 0, 0,,% "ahk_id " this.hwnd
				Value := this._.Items[ErrorLevel + 1]
			}
			else if(Name = "Text")
				ControlGet, Value, Choice,,,% "ahk_id " this.hwnd
			else if(Name = "SelectedIndex")
			{
				SendMessage, 0x147, 0, 0,,% "ahk_id " this.hwnd
				Value := ErrorLevel + 1
			}
			else if(Name = "Items")
				Value := this._.Items
			else if(Name = "PreviouslySelectedItem")
				Value := this._.PreviouslySelectedItem
			;~ else if(Name = "Items")
			;~ {
				;~ ControlGet, List, List,,, % " ahk_id " this.hwnd
				;~ Value := Array()
				;~ Loop, Parse, List, `n
					;~ Value.Insert(A_LoopField)			
			;~ }
			Loop % Params.MaxIndex()
				if(IsObject(Value)) ;Fix unlucky multi parameter __GET
					Value := Value[Params[A_Index]]
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Value != "")
				return Value
		}
	}
	__Set(Name, Params*)
	{
		;~ global CGUI
		if(!CGUI.GUIList[this.GUINum].IsDestroyed)
		{
			Value := Params[Params.MaxIndex()]
			Params.Remove(Params.MaxIndex())
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			Handled := true
			if(Name = "SelectedItem")
			{
				Loop % this.Items.MaxIndex()
					if(this.Items[A_Index] = Value)
					{
						GuiControl, % this.GUINum ":Choose", % this.ClassNN, % A_Index
						this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
						this._.PreviouslySelectedItem := this.SelectedItem
					}
			}
			else if(Name = "SelectedIndex" && Value >= 1 && Value <= this.Items.MaxIndex())
			{
				GuiControl, % this.GUINum ":Choose", % this.ClassNN, % Value
				this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
				this._.PreviouslySelectedItem := this.SelectedItem
			}
			;~ else if(Name = "Items" && !Params[1])
			;~ {
				;~ if(!IsObject(Value))
				;~ {
					;~ if(InStr(Value, "|") = 1) ;Overwrite current items
					;~ {						
						;~ ;Hide overwritten controls for now (until they can be removed properly).
						;~ for index, item in this.Items
							;~ for index2, control in item.Controls
								;~ control.hide()
						;~ this.Items := new this.CItems(this.GUINum, this.Name)
					;~ }
					;~ Loop, Parse, Value,|
						;~ if(A_LoopField)
							;~ this.Items.Insert(this.Items.MaxIndex() + 1, new this.CItems.CItem(this.Items.MaxIndex() + 1, this.GUINum, this.Name))
				;~ }
				;~ else
				;~ {
					;~ ;Hide overwritten controls for now (until they can be removed properly).
					;~ for index, item in this.Items
						;~ for index2, control in item.Controls
							;~ control.hide()
					;~ this.Items := new this.CItems(this.GUINum, this.Name)
					;~ Loop % Value.MaxIndex()
						;~ this.Items.Insert(A_Index, new this.CItems.CItem(A_Index, this.GUINum, this.Name))
				;~ }
				;~ ItemsString := ""
				;~ Loop % this.Items.MaxIndex()
					;~ ItemsString .= "|" Items[A_Index]
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ if(!IsObject(Value) && InStr(Value, "||"))
				;~ {
					;~ if(RegExMatch(Value, "(?:^|\|)(..*?)\|\|", SelectedItem))
						;~ Control, ChooseString, %SelectedItem1%,,% "ahk_id " this.hwnd
				;~ }
				;~ for index, item in Items
					;~ this.Items._.Insert(new this.CItems.CItem(A_Index, this.GUINum, this.Name))
			;~ }
			;~ else if(Name = "Items" && Params[1] > 0)
			;~ {
				;~ this._.Items[Params[1]] := Value
				;~ msgbox should not be here
				;~ Items := this.Items
				;~ Items[Params[1]] := Value
				;~ ItemsString := ""
				;~ Loop % Items.MaxIndex()
					;~ ItemsString .= "|" Items[A_Index]
				;~ SelectedIndex := this.SelectedIndex
				;~ GuiControl, % this.GUINum ":", % this.ClassNN, %ItemsString%
				;~ GuiControl, % this.GUINum ":Choose", % this.ClassNN, %SelectedIndex%
			;~ }
			else if(Name = "Text")
			{
				found := false
				Loop % this.Items.MaxIndex()
					if(this.Items[A_Index].Text = Value)
					{
						GuiControl, % this.GUINum ":Choose", % this.ClassNN, % A_Index
						this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
						this._.PreviouslySelectedItem := this.SelectedItem
						found := true
					}
				if(!found && this.type = "ComboBox")
					ControlSetText, , %Value%, % "ahk_id " this.hwnd
				;~ {
					;~ GuiControl, % this.GUINum ":ChooseString", % this.ClassNN, % Value
					;~ this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
					;~ this._.PreviouslySelectedItem := this.SelectedItem
				;~ }
			}
			else
				Handled := false
			if(!DetectHidden)
				DetectHiddenWindows, Off
			if(Handled)
				return Value
		}
	}
	/*
	Event: Introduction
	To handle control events you need to create a function with this naming scheme in your window class: ControlName_EventName(params)
	The parameters depend on the event and there may not be params at all in some cases.
	Additionally it is required to create a label with this naming scheme: GUIName_ControlName
	GUIName is the name of the window class that extends CGUI. The label simply needs to call CGUI.HandleEvent(). 
	For better readability labels may be chained since they all execute the same code.
	Instead of using ControlName_EventName() you may also call <CControl.RegisterEvent> on a control instance to register a different event function name.
	
	Event: SelectionChanged(SelectedItem)
	Invoked when the selection was changed.
	*/
	HandleEvent(Event)
	{
		this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
		this._.PreviouslySelectedItem := this.SelectedItem
		this.CallEvent("SelectionChanged", this.SelectedItem)
	}
	/*
	Class: CChoiceControl.CItems
	An array containing all items of the control.
	*/
	Class CItems
	{
		__New(GUINum, hwnd)
		{
			this.Insert("_", {})
			this._.GUINum := GUINum
			this._.hwnd := hwnd
		}
		
		/*
		Variable: 1,2,3,4,...
		Individual items can be accessed by their index.
		
		Variable: Count
		The number of items in this control.
		*/		
		__Get(Name)
		{
			;~ global CGUI
			if(this._.HasKey(Name))
				return this._[Name]
			else if(Name = "Count")
				return this.MaxIndex()
		}
		__Set(Name, Value)
		{
			;~ global CGUI
			if Name is Integer
				return
		}
		/*
		Function: Add
		Adds an item to the list of choices.
		
		Parameters:
			Text - The text of the new item.
			Position - The position at which the item will be inserted. Items with indices >= this value will be appended.
		*/
		Add(Text, Position = -1)
		{
			;~ global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this._.hwnd]
			Selected := Control.SelectedIndex
			ItemsString := ""
			Pos := 1
			Loop % this.MaxIndex()
			{
				ItemsString .= "|" (Position = A_Index ? Text : this[pos].Text)
				if(Position = A_Index)
					pos--
				pos++
			}
			if(Position = -1)
				ItemsString .= "|" Text
			GuiControl, % this._.GUINum ":", % Control.ClassNN, %ItemsString%
			this._.Insert(Position = -1 ? this.MaxIndex() + 1 : Position, new this.CItems.CItem(Position, this._.GUINum, this.Name)) ;Insert new item object
			for index, item in this ;Move existing indices
				item._.Index := index
			GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, % (Position != -1 && Selected < Position ? Selected : Selected + 1)
		}
		/*
		Function: Remove
		Removes an item to the list of choices.
		
		Parameters:
			IndexTextOrItem - The item which should be removed. This can either be an index, the text of the item or the item object stored in the Items array.
		*/
		Remove(IndexTextOrItem)
		{
			;~ global CGUI
			GUI := CGUI.GUIList[this._.GUINum]
			Control := GUI.Controls[this.hwnd]
			if(IsObject(IndexTextOrItem))
			{
				Loop % this.MaxIndex()
					if(this[A_Index] = IndexTextOrItem)
						IndexTextOrItem := A_Index
			}
			else if IndexTextOrItem is not Integer
			{
				Loop % this.MaxIndex()
					if(this[A_Index].Text = IndexTextOrItem)
						IndexTextOrItem := A_Index
			}
			if IndexTextOrItem is Number
			{
				if(IndexTextOrItem > 0 && IndexTextOrItem <= this.MaxIndex())
				{
					Selected := Control.SelectedIndex
					this._.Remove(IndexTextOrItem)
					ItemsString := ""
					Loop % this.MaxIndex()
						if(A_Index != IndexTextOrItem)
							ItemsString .= "|" this[A_Index]
					GuiControl, % this.GUINum ":Choose", % Control.ClassNN, % (Selected <= IndexTextOrItem ? Selected : Selected - 1)
					for index, item in this
						item._.Index := index
				}
			}
		}
		/*
		Function: MaxIndex
		Returns the number of items in this control.
		*/
		MaxIndex()
		{
			;~ global CGUI
			DetectHidden := A_DetectHiddenWindows
			DetectHiddenWindows, On
			GUI := CGUI.GUIList[this._.GUINum]
			ControlGet, List, List,,, % " ahk_id " this._.hwnd
			count := 0
			Loop, Parse, List, `n
				count++
			if(!DetectHidden)
				DetectHiddenWindows, Off
			return count
		}
		_NewEnum()
		{
			;~ global CEnumerator
			return new CEnumerator(this)
		}
		/*
		Class: CChoiceControl.CItems.CItem
		A single item of this control.
		*/
		Class CItem
		{
			__New(Index, GUINum, hwnd)
			{
				this.Insert("_", {})
				this._.Insert("GUINum", GUINum)
				this._.Insert("hwnd", hwnd)
				this._.Insert("Index", Index)
				this._.Insert("Controls", {})
			}
			/*
			Function: AddControl
			Adds a control to this item that will be visible only when this item is selected. The parameters correspond to the Add() function of CGUI.
			
			Parameters:
				Type - The type of the control.
				Name - The name of the control.
				Options - Options used for creating the control.
				Text - The text of the control.
				UseEnabledState - If true, the control will be enabled/disabled instead of visible/hidden.
			*/
			AddControl(type, Name, Options, Text, UseEnabledState = 0)
			{
				;~ global CGUI
				GUI := CGUI.GUIList[this._.GUINum]
				if(!this.Selected)
					Options .= UseEnabledState ? " Disabled" : " Hidden"
				Control := GUI.AddControl(type, Name, Options, Text, this._.Controls)
				Control._.UseEnabledState := UseEnabledState
				this._.Controls.Insert(Name, Control)
				return Control
			}
			/*
			Variable: Selected
			If true, the item is selected.
			
			Variable: Text
			The text of the list item.
			*/
			__Get(Name, Params*)
			{
				;~ global CGUI
				DetectHidden := A_DetectHiddenWindows
				DetectHiddenWindows, On
				if(Name = "Text")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					ControlGet, List, List,,, % " ahk_id " Control.hwnd
					Loop, Parse, List, `n
						if(A_Index = this._.Index)
						{
							Value := A_LoopField
							break
						}
				}
				else if(Name = "Selected")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					SendMessage, 0x147, 0, 0,,% "ahk_id " Control.hwnd
					Value := (this._.Index = ErrorLevel + 1)
				}
				else if(Name = "Controls")
					Value := this._.Controls
				Loop % Params.MaxIndex()
					if(IsObject(Value)) ;Fix unlucky multi parameter __GET
						Value := Value[Params[A_Index]]
				if(!DetectHidden)
					DetectHiddenWindows, Off
				return Value
			}
			__Set(Name, Value)
			{
				;~ global CGUI
				if(Name = "Text")
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					ItemsString := ""
					SelectedIndex := Control.SelectedIndex
					for index, item in Control.Items
						ItemsString .= "|" (index = this._.Index ? Value : item.text)
					GuiControl, % this._.GUINum ":", % Control.ClassNN, %ItemsString%
					GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, %SelectedIndex%
					return Value
				}
				else if(Name = "Selected" && Value = 1)
				{
					GUI := CGUI.GUIList[this._.GUINum]
					Control := GUI.Controls[this._.hwnd]
					GuiControl, % this._.GUINum ":Choose", % Control.ClassNN, % this._.Index
					this.ProcessSubControlState(this._.PreviouslySelectedItem, this.SelectedItem)
					Control._.PreviouslySelectedItem := Control.SelectedItem
					return Value
				}
			}
		}
	}
}
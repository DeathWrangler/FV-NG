package Widgets.Buttons
{
   import Engine.Utilities;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Interfaces.IZwToggle;
   import Widgets.Core.Managers.ZwActiveWidgetManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class FarmTabButton extends FarmButton implements IZwToggle
   {
      
      protected var m_textSelectedHandle:uint = 4294967295;
      
      protected var m_textDeselectedHandle:uint = 4294967295;
      
      protected var m_textDisabledHandle:uint = 4294967295;
      
      protected var m_downStateHandle:uint = 4294967295;
      
      protected var m_overStateHandle:uint = 4294967295;
      
      protected var m_upStateHandle:uint = 4294967295;
      
      protected var m_disabledStateHandle:uint = 4294967295;
      
      protected var m_activeTextManager:ZwActiveWidgetManager = null;
      
      protected var m_activeStateManager:ZwActiveWidgetManager = null;
      
      protected var m_lockIcon:DisplayObject = null;
      
      public function FarmTabButton(element:DisplayObjectContainer, text:String = "", callback:Function = null, textColor:String = null)
      {
         super(element,callback);
         this.m_activeTextManager = new ZwActiveWidgetManager();
         this.m_activeStateManager = new ZwActiveWidgetManager();
         this.m_textSelectedHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitle_tf,text));
         this.m_textDeselectedHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitleLight_tf,text),true);
         this.m_textDisabledHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitleDisabled_tf,text));
         this.m_downStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabDown_mc));
         this.m_overStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabOver_mc));
         this.m_upStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabUp_mc),true);
         this.m_disabledStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabDisabled_mc));
         if(textColor)
         {
            if(this.m_activeStateManager.getWidget(this.m_downStateHandle).element["color_mc"])
            {
               TemplateUIUtility.applyBackgroundColor(this.m_activeStateManager.getWidget(this.m_downStateHandle).element["color_mc"],TemplateUIUtility.VOTING,textColor);
            }
            if(this.m_activeStateManager.getWidget(this.m_overStateHandle).element["color_mc"])
            {
               TemplateUIUtility.applyBackgroundColor(this.m_activeStateManager.getWidget(this.m_overStateHandle).element["color_mc"],TemplateUIUtility.VOTING,textColor);
            }
            if(this.m_activeStateManager.getWidget(this.m_upStateHandle).element["color_mc"])
            {
               TemplateUIUtility.applyBackgroundColor(this.m_activeStateManager.getWidget(this.m_upStateHandle).element["color_mc"],TemplateUIUtility.VOTING,textColor);
            }
            if(this.m_activeStateManager.getWidget(this.m_disabledStateHandle).element["color_mc"])
            {
               TemplateUIUtility.applyBackgroundColor(this.m_activeStateManager.getWidget(this.m_disabledStateHandle).element["color_mc"],TemplateUIUtility.VOTING,textColor);
            }
         }
         if(m_element.hasOwnProperty("lockIcon_mc"))
         {
            this.m_lockIcon = m_element.lockIcon_mc as DisplayObject;
            this.m_lockIcon.visible = false;
         }
         this.registerEventListeners();
         m_element.buttonMode = true;
         Utilities.toggleInputOnlyChildren(m_element as DisplayObjectContainer,false);
         var textFieldContainer:Sprite = new Sprite();
         m_element.addChild(textFieldContainer);
         textFieldContainer.addChild(m_element.tabTitle_tf as DisplayObject);
         textFieldContainer.addChild(m_element.tabTitleLight_tf as DisplayObject);
         textFieldContainer.addChild(m_element.tabTitleDisabled_tf as DisplayObject);
         Utilities.toggleInputAndChildren(textFieldContainer,false);
      }
      
      override public function release() : void
      {
         this.m_activeTextManager.release();
         this.m_activeTextManager = null;
         this.m_activeStateManager.release();
         this.m_activeStateManager = null;
         this.m_lockIcon = null;
         super.release();
      }
      
      public function startListenForToggle(callback:Function) : void
      {
         registerEventListener(MouseEvent.CLICK,callback);
      }
      
      public function stopListenForToggle(callback:Function) : void
      {
         unregisterEventListener(MouseEvent.CLICK,callback);
      }
      
      public function setToggleState(toggleState:String) : void
      {
         switch(toggleState)
         {
            case ZwToggleState.SELECTED:
               this.unregisterEventListeners();
               this.showDownState(null);
               break;
            case ZwToggleState.DESELECTED:
               this.registerEventListeners();
               this.showUpState(null);
               break;
            case ZwToggleState.DISABLED:
               this.unregisterEventListeners();
               this.showDisabledState(null);
         }
      }
      
      public function setToggleMode(toggleMode:String) : void
      {
      }
      
      public function get lockIconVisible() : Boolean
      {
         var result:Boolean = false;
         if(this.m_lockIcon)
         {
            result = this.m_lockIcon.visible;
         }
         return result;
      }
      
      public function set lockIconVisible(isVisible:Boolean) : void
      {
         if(this.m_lockIcon)
         {
            this.m_lockIcon.visible = isVisible;
         }
      }
      
      public function get text() : String
      {
         var value:String = "";
         var textField:ZwTextField = this.m_activeTextManager.getWidget(this.m_textDeselectedHandle) as ZwTextField;
         if(textField)
         {
            value = textField.text;
         }
         return value;
      }
      
      public function set text(value:String) : void
      {
         var textField:ZwTextField = null;
         textField = this.m_activeTextManager.getWidget(this.m_textDeselectedHandle) as ZwTextField;
         if(textField)
         {
            textField.text = value;
         }
         textField = this.m_activeTextManager.getWidget(this.m_textDisabledHandle) as ZwTextField;
         if(textField)
         {
            textField.text = value;
         }
         textField = this.m_activeTextManager.getWidget(this.m_textSelectedHandle) as ZwTextField;
         if(textField)
         {
            textField.text = value;
         }
      }
      
      protected function registerEventListeners() : void
      {
         registerEventListener(MouseEvent.MOUSE_OVER,this.showOverState);
         registerEventListener(MouseEvent.MOUSE_DOWN,this.showDownState);
         registerEventListener(MouseEvent.MOUSE_UP,this.showUpState);
         registerEventListener(MouseEvent.MOUSE_OUT,this.showOutState);
      }
      
      protected function unregisterEventListeners() : void
      {
         unregisterEventListener(MouseEvent.MOUSE_OVER,this.showOverState);
         unregisterEventListener(MouseEvent.MOUSE_DOWN,this.showDownState);
         unregisterEventListener(MouseEvent.MOUSE_UP,this.showUpState);
         unregisterEventListener(MouseEvent.MOUSE_OUT,this.showOutState);
      }
      
      protected function showOverState(event:MouseEvent) : void
      {
         this.m_activeTextManager.selectWidget(this.m_textSelectedHandle);
         this.m_activeStateManager.selectWidget(this.m_overStateHandle);
      }
      
      protected function showDownState(event:MouseEvent) : void
      {
         this.m_activeTextManager.selectWidget(this.m_textSelectedHandle);
         this.m_activeStateManager.selectWidget(this.m_downStateHandle);
      }
      
      protected function showUpState(event:MouseEvent) : void
      {
         this.m_activeTextManager.selectWidget(this.m_textDeselectedHandle);
         this.m_activeStateManager.selectWidget(this.m_upStateHandle);
      }
      
      protected function showOutState(event:MouseEvent) : void
      {
         this.m_activeTextManager.selectWidget(this.m_textDeselectedHandle);
         this.m_activeStateManager.selectWidget(this.m_upStateHandle);
      }
      
      protected function showDisabledState(event:MouseEvent) : void
      {
         this.m_activeTextManager.selectWidget(this.m_textDisabledHandle);
         this.m_activeStateManager.selectWidget(this.m_disabledStateHandle);
      }
   }
}


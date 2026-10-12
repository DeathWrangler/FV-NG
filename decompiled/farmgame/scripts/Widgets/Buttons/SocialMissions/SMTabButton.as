package Widgets.Buttons.SocialMissions
{
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Constants.ZwToggleState;
   import Widgets.Core.Interfaces.IZwToggle;
   import Widgets.Core.Managers.ZwActiveWidgetManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   
   public class SMTabButton extends FarmButton implements IZwToggle
   {
      
      protected var m_textSelectedHandle:uint = 4294967295;
      
      protected var m_textDeselectedHandle:uint = 4294967295;
      
      protected var m_textDisabledHandle:uint = 4294967295;
      
      protected var m_downStateHandle:uint = 4294967295;
      
      protected var m_overStateHandle:uint = 4294967295;
      
      protected var m_upStateHandle:uint = 4294967295;
      
      protected var m_disabledStateHandle:uint = 4294967295;
      
      protected var m_newStarBurstHandle:uint = 4294967295;
      
      protected var m_activeTextManager:ZwActiveWidgetManager = null;
      
      protected var m_activeStateManager:ZwActiveWidgetManager = null;
      
      protected var m_activeNewManager:ZwActiveWidgetManager = null;
      
      protected var m_isNew:Boolean = false;
      
      protected var m_buttonText:String = "";
      
      protected var m_buttonId:String = null;
      
      public function SMTabButton(element:DisplayObjectContainer, text:String = "", callback:Function = null, buttonId:String = "", isNew:Boolean = false)
      {
         super(element,callback);
         this.m_activeTextManager = new ZwActiveWidgetManager();
         this.m_activeStateManager = new ZwActiveWidgetManager();
         this.m_activeNewManager = new ZwActiveWidgetManager();
         this.m_buttonText = text;
         this.m_buttonId = buttonId;
         this.m_isNew = isNew;
         if(m_element.burstNew_mc)
         {
            this.m_newStarBurstHandle = this.m_activeNewManager.addWidget(new ZwWidget(m_element.burstNew_mc));
         }
         this.m_textSelectedHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitle_tf,text));
         this.m_textDeselectedHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitleLight_tf,text),true);
         this.m_textDisabledHandle = this.m_activeTextManager.addWidget(new ZwTextField(m_element.tabTitleDisabled_tf,text));
         this.m_downStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabDown_mc));
         this.m_overStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabOver_mc));
         this.m_upStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabUp_mc),true);
         this.m_disabledStateHandle = this.m_activeStateManager.addWidget(new ZwWidget(m_element.tabDisabled_mc));
         this.registerEventListeners();
         this.setToggleState(ZwToggleState.SELECTED);
         this.setToggleState(ZwToggleState.DESELECTED);
      }
      
      override public function release() : void
      {
         this.m_activeTextManager.release();
         this.m_activeTextManager = null;
         this.m_activeStateManager.release();
         this.m_activeStateManager = null;
         this.m_activeNewManager.release();
         this.m_activeNewManager = null;
         super.release();
      }
      
      public function get buttonText() : String
      {
         return this.m_buttonText;
      }
      
      public function get buttonId() : String
      {
         return this.m_buttonId;
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
      
      private function toggleNewIcon() : void
      {
         if(this.m_isNew)
         {
            this.m_activeNewManager.selectWidget(this.m_newStarBurstHandle);
         }
      }
      
      protected function showOverState(event:MouseEvent) : void
      {
         this.toggleNewIcon();
         this.m_activeTextManager.selectWidget(this.m_textSelectedHandle);
         this.m_activeStateManager.selectWidget(this.m_overStateHandle);
      }
      
      protected function showDownState(event:MouseEvent) : void
      {
         this.toggleNewIcon();
         this.m_activeTextManager.selectWidget(this.m_textSelectedHandle);
         this.m_activeStateManager.selectWidget(this.m_downStateHandle);
      }
      
      protected function showUpState(event:MouseEvent) : void
      {
         this.toggleNewIcon();
         this.m_activeTextManager.selectWidget(this.m_textDeselectedHandle);
         this.m_activeStateManager.selectWidget(this.m_upStateHandle);
      }
      
      protected function showOutState(event:MouseEvent) : void
      {
         this.toggleNewIcon();
         this.m_activeTextManager.selectWidget(this.m_textDeselectedHandle);
         this.m_activeStateManager.selectWidget(this.m_upStateHandle);
      }
      
      protected function showDisabledState(event:MouseEvent) : void
      {
         this.toggleNewIcon();
         this.m_activeTextManager.selectWidget(this.m_textDisabledHandle);
         this.m_activeStateManager.selectWidget(this.m_disabledStateHandle);
      }
   }
}


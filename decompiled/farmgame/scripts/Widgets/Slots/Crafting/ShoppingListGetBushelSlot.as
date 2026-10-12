package Widgets.Slots.Crafting
{
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.SmartBushelHelper;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class ShoppingListGetBushelSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private static const ICON_X:int = 5;
      
      private static const ICON_Y:int = 5;
      
      private var m_uid:String = "0";
      
      private var m_timeRemaining:Number;
      
      private var m_lastTime:Number;
      
      private var m_icon:FarmIcon;
      
      private var m_getButton:FarmAnimatedTextButton;
      
      private var m_timeRemainingTextField:ZwTextField;
      
      private var m_getItemCallback:Function;
      
      public function ShoppingListGetBushelSlot(element:DisplayObject, getItemCallback:Function)
      {
         this.m_getItemCallback = getItemCallback;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.x = ICON_X;
         this.m_icon.y = ICON_Y;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_timeRemainingTextField = addWidget(new ZwTextField(m_element.generic_tf,""),false) as ZwTextField;
         this.m_getButton = addWidget(new FarmAnimatedTextButton(m_element.get_bt,ZLocUtils.t("Crafting","ShoppingListDialog_GetButton"),this.onGetButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         if(data)
         {
            this.m_uid = data["uid"];
            if(SmartBushelHelper.inExperiment() && this.m_uid == SmartBushelHelper.FICTIONAL_CHARACTER_ID)
            {
               this.m_icon.loadIcon(SmartBushelHelper.getFriendData().picture);
            }
            else
            {
               this.m_icon.loadIcon(FarmGameUtil.getFriendIconByUid(this.m_uid));
            }
            this.m_icon.visible = true;
            if(Number(data["timeToBags"]) > 0)
            {
               this.m_timeRemaining = Number(data["timeToBags"]);
               this.m_lastTime = GlobalEngine.currentTime;
               this.m_timeRemainingTextField.text = ZLocUtils.t("Crafting","MarketViewDialog_TimeRemaining",{"timestr":FarmGameUtil.toFriendlyTime(this.m_timeRemaining)});
               this.m_timeRemainingTextField.registerEventListener(Event.ENTER_FRAME,this.onEnterFrameTimeRemainingHandler);
               this.m_timeRemainingTextField.visible = true;
               this.m_getButton.enabled = this.m_getButton.visible = false;
            }
            else
            {
               this.m_getButton.enabled = this.m_getButton.visible = true;
               this.m_timeRemainingTextField.visible = false;
            }
         }
      }
      
      private function onEnterFrameTimeRemainingHandler(event:Event) : void
      {
         var deltaTime:Number = (GlobalEngine.currentTime - this.m_lastTime) / 1000;
         this.m_lastTime = GlobalEngine.currentTime;
         this.m_timeRemaining = Math.max(this.m_timeRemaining - deltaTime,0);
         this.m_timeRemainingTextField.text = ZLocUtils.t("Crafting","MarketViewDialog_TimeRemaining",{"timestr":FarmGameUtil.toFriendlyTime(this.m_timeRemaining)});
      }
      
      private function onGetButtonClick(evt:Event) : void
      {
         if(this.m_getButton.enabled)
         {
            this.m_getButton.enabled = false;
            if(this.m_getItemCallback != null && Boolean(this.m_uid))
            {
               this.m_getItemCallback(this.m_uid);
            }
         }
      }
      
      override public function release() : void
      {
         super.release();
         this.m_icon = null;
         this.m_getButton = null;
         this.m_timeRemainingTextField = null;
         this.m_getItemCallback = null;
      }
   }
}


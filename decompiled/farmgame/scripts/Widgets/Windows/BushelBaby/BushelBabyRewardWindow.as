package Widgets.Windows.BushelBaby
{
   import Classes.Animal;
   import Classes.BushelBaby.BushelBabySystem;
   import Classes.Constants.ZLocConstants;
   import Classes.util.DisplayObjectUtils;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.BushelBabyManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ResourcePreviewFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class BushelBabyRewardWindow extends FarmWindow
   {
      
      public static var m_rewardWindowStaticInstance:BushelBabyRewardWindow;
      
      public static const REWARD_TYPE_1:int = 1;
      
      public static const REWARD_TYPE_2:int = 2;
      
      private var m_reward_type:int;
      
      private var m_reward_item:Array;
      
      private var m_icon_url:Array = new Array();
      
      private var m_item:Array = new Array();
      
      private var m_icon:Array = new Array();
      
      private var m_textButton:Array = new Array();
      
      private var m_subtext:String;
      
      private var m_subtext_2:String;
      
      private var m_system:BushelBabySystem;
      
      private var m_npcName:String;
      
      private var m_showShare:Boolean;
      
      private var m_showClose:Boolean;
      
      private var m_shareCallBack:Function;
      
      private var m_rewardSelectCallBack:Function;
      
      private var m_closeCallBack:Function;
      
      private var m_onShareAndCloseCallBack:Function;
      
      public function BushelBabyRewardWindow(system:BushelBabySystem, npcName:String, rewardType:int, rewardItem:Array, subtext:String, subtext_2:String, showShare:Boolean, showClose:Boolean, shareCallBack:Function, rewardSelectCallBack:Function, closeCallBack:Function, onShareAndCloseCallBack:Function)
      {
         m_rewardWindowStaticInstance = this;
         this.m_reward_type = rewardType;
         this.m_reward_item = rewardItem;
         this.m_npcName = npcName;
         this.m_system = system;
         this.m_subtext = subtext;
         this.m_subtext_2 = subtext_2;
         this.m_showShare = showShare;
         this.m_showClose = showClose;
         this.m_shareCallBack = shareCallBack;
         this.m_rewardSelectCallBack = rewardSelectCallBack;
         this.m_closeCallBack = closeCallBack;
         this.m_onShareAndCloseCallBack = onShareAndCloseCallBack;
         super(system.getAssetUrl(BushelBabySystem.ASSET_DIALOG_REWARD));
      }
      
      public static function display(system:BushelBabySystem, npcName:String, rewardType:int, farmItem:Array, subtext:String, subtext_2:String, showShare:Boolean, showClose:Boolean, shareCallBack:Function, rewardSelectCallBack:Function, closeCallBack:Function, onShareAndCloseCallBack:Function) : BushelBabyRewardWindow
      {
         var window:BushelBabyRewardWindow = null;
         if(system)
         {
            window = new BushelBabyRewardWindow(system,npcName,rewardType,farmItem,subtext,subtext_2,showShare,showClose,shareCallBack,rewardSelectCallBack,closeCallBack,onShareAndCloseCallBack);
            UI.displayPopup(window,false,"BushelBabyRewardWindow",true);
         }
         return window;
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"AnimalBreedingFForestZoo_finishedReward_WindowTitle")),true);
         if(this.m_reward_type == REWARD_TYPE_1)
         {
            this.displayOneReward();
         }
         else
         {
            this.displayMultipleRewards();
         }
         addWidget(new ZwTextField(m_window.generic2_tf,this.m_subtext),true);
         addWidget(new ZwTextField(m_window.generic3_tf,this.m_subtext_2),true);
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         super.onLoadComplete(event);
         this.setCloseButtonVisible(this.m_showClose);
      }
      
      private function displayOneReward(index:int = 0) : void
      {
         var previeFrame:ResourcePreviewFrame = null;
         this.m_icon_url[0] = this.m_reward_item[index].getImageByName("icon",false);
         var exportNames:Array = this.m_reward_item[index].getExpectedExportNames();
         this.m_icon[0] = addWidget(previeFrame = new ResourcePreviewFrame(m_window.item_mc));
         previeFrame.load(this.m_reward_item[index].imageRelativeUrl(Animal.STATE_FRONT_IDLE),this.m_reward_item[index].name + "_" + exportNames[0],this.getOnImageLoadClosure(previeFrame,m_window.item_mc.icon_mc));
         if(this.m_showShare)
         {
            this.m_textButton[0] = addWidget(new FarmAnimatedTextButton(m_window.accept_bt,"Share!",this.onShareButtonClick(this.m_reward_item[index].name)));
            BushelBabyManager.grantReward(this.m_reward_item[index].name);
         }
      }
      
      private function displayMultipleRewards() : void
      {
         var previeFrame:ResourcePreviewFrame = null;
         var exportNames:Array = null;
         for(var i:int = 0; i < this.m_reward_type; i++)
         {
            this.m_icon_url[i] = this.m_reward_item[i].getImageByName("icon",false);
            this.m_item[i] = addWidget(new ZwFrame(m_window["item" + i + "_mc"]));
            exportNames = this.m_reward_item[i].getExpectedExportNames();
            this.m_icon[i] = this.m_item[i].addWidget(previeFrame = new ResourcePreviewFrame(m_window["item" + i + "_mc"]["icon_mc"]));
            previeFrame.load(this.m_reward_item[i].imageRelativeUrl(Animal.STATE_FRONT_IDLE),this.m_reward_item[i].name + "_" + exportNames[0],this.getOnImageLoadClosure(previeFrame,m_window.item_mc.icon_mc));
            this.m_textButton[i] = this.m_item[i].addWidget(new FarmAnimatedTextButton(m_window["item" + i + "_mc"].accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"pickMe"),this.onRewardSelected(i)));
         }
      }
      
      private function getOnImageLoadClosure(previeFrame:ResourcePreviewFrame, icon:DisplayObject) : Function
      {
         return function():void
         {
            DisplayObjectUtils.fitDisplayObject(previeFrame.exportedMovieClip,icon.width,icon.height,true);
            var mc:* = previeFrame.exportedMovieClip;
            if(mc.height > icon.height * 1.5)
            {
               mc.scaleX = mc.scaleY = icon.height * 1.5 / mc.height;
            }
            mc.x = (icon.width - mc.width) / 2;
            if(previeFrame.exportName == "seal_balloon_frt_idle")
            {
               mc.scaleX = mc.scaleY = 1.5;
               mc.y -= 80;
               mc.x -= 30;
            }
            if(previeFrame.exportName == "pegasus_mini_starryminipegasus_frt_idle")
            {
               mc.scaleX = mc.scaleY = 3;
               mc.y -= 80;
               mc.x -= 70;
            }
         };
      }
      
      private function onRewardSelected(rewardIndex:int) : Function
      {
         var f:Function;
         this.m_system.logStats("pick_me",this.m_reward_item[rewardIndex].name);
         f = function(event:Event):void
         {
            if(m_rewardSelectCallBack != null)
            {
               m_rewardSelectCallBack(m_reward_item[rewardIndex].name);
            }
            if(m_closeButton.enabled)
            {
               onClose(event);
            }
         };
         return f;
      }
      
      override protected function release() : void
      {
         this.m_reward_item = null;
         m_rewardWindowStaticInstance = null;
         this.m_icon_url = null;
         this.m_item = null;
         this.m_icon = null;
         this.m_textButton = null;
         this.m_subtext = null;
         this.m_subtext_2 = null;
         this.m_npcName = null;
         this.m_system = null;
         this.m_showShare = false;
         this.m_showClose = false;
         this.m_shareCallBack = null;
         this.m_rewardSelectCallBack = null;
         this.m_closeCallBack = null;
         this.m_onShareAndCloseCallBack = null;
         super.release();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_closeCallBack != null)
         {
            this.m_closeCallBack();
         }
         if(this.m_onShareAndCloseCallBack != null)
         {
            this.m_onShareAndCloseCallBack();
         }
         if(m_closeButton.enabled)
         {
            super.onClose(event);
         }
      }
      
      public function get rewardItem() : Array
      {
         return this.m_reward_item;
      }
      
      public function onShareButtonClick(itemId:String) : Function
      {
         var f:Function = function(event:Event):void
         {
            var params:Array = new Array(m_system.name,itemId);
            if(m_shareCallBack != null)
            {
               m_shareCallBack(m_system,m_npcName,itemId);
            }
            if(m_onShareAndCloseCallBack != null)
            {
               m_onShareAndCloseCallBack();
            }
            close();
         };
         return f;
      }
   }
}


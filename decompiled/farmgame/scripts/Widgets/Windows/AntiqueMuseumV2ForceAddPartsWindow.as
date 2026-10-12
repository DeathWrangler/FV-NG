package Widgets.Windows
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Managers.AntiqueMuseumV2Manager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class AntiqueMuseumV2ForceAddPartsWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardIcon:FarmIcon = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var body_tf:ZwTextField;
      
      protected var body1_tf:ZwTextField;
      
      protected var m_bonus_mc:MovieClip;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgLoader:ImageLoader = null;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_gift_mc:MovieClip = new MovieClip();
      
      private var m_rewardImage:String = null;
      
      private var m_isLBReward:Boolean = false;
      
      private var m_accept_bt:FarmButton;
      
      private var m_okaybutton:FarmButton;
      
      private var m_pieceName:String = "";
      
      private var m_synkPartsMC:MovieClip;
      
      private var m_isMilestone:Boolean = false;
      
      public function AntiqueMuseumV2ForceAddPartsWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, dialogBackground:String = null, rewardIcon:String = null, pieceName:String = "", isMilestone:* = false)
      {
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_rewardImage = rewardIcon;
         this.m_pieceName = pieceName;
         this.m_isMilestone = isMilestone;
         super(dialogAsset);
      }
      
      private function onBgLoad(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_bgIcon = dispObj;
      }
      
      override protected function postLoadComplete() : void
      {
         var buttonCallback:Function = null;
         super.postLoadComplete();
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("synk_parts"))
            {
               this.m_synkPartsMC = m_window["synk_parts"] as MovieClip;
               this.m_synkPartsMC.visible = true;
               if(this.m_synkPartsMC.hasOwnProperty("syn_bt"))
               {
                  buttonCallback = new Function();
                  buttonCallback = onClose;
                  if(this.m_callback != null)
                  {
                     buttonCallback = this.m_callback;
                  }
                  this.m_okaybutton = new FarmAnimatedTextButton(this.m_synkPartsMC.syn_bt,"Okay",buttonCallback);
                  this.m_okaybutton.visible = true;
               }
            }
         }
         if(this.manager)
         {
            if(this.manager.mainWindow)
            {
               this.manager.mainWindow.tintWindow();
               this.manager.mainWindow.enableInput = false;
            }
         }
      }
      
      private function get manager() : AntiqueMuseumV2Manager
      {
         return AntiqueMuseumV2Manager.getInstance();
      }
   }
}


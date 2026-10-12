package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class PetAcademyProfessionGrantWindow extends FarmWindow
   {
      
      private static const OFFSET_OPF_Y:int = -30;
      
      protected var m_featureName:String = null;
      
      private var m_reward:FarmItem = null;
      
      private var m_callback:Function = null;
      
      protected var title_tf:ZwTextField = null;
      
      protected var m_zoomingScale:int = 3;
      
      private var m_bgIcon:DisplayObject = null;
      
      private var m_animalName:String;
      
      public function PetAcademyProfessionGrantWindow(dialogAsset:String, featureName:String, rewardItem:FarmItem = null, buttonCallback:Function = null, animalName:String = null)
      {
         super(dialogAsset);
         this.m_reward = rewardItem;
         this.m_featureName = featureName;
         this.m_callback = buttonCallback;
         this.m_animalName = animalName;
      }
      
      override protected function postLoadComplete() : void
      {
         var shareCallback:Function = null;
         super.postLoadComplete();
         var itemName:String = "";
         if(this.m_reward != null)
         {
            itemName = this.m_reward.friendlyTitle;
         }
         if(m_window != null)
         {
            if(m_window.hasOwnProperty("generic_tf"))
            {
               this.title_tf = addWidget(new ZwTextField(m_window["generic_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Profession_GenericText"))) as ZwTextField;
            }
            if(m_window.hasOwnProperty("generic2_tf"))
            {
               addWidget(new ZwTextField(m_window["generic2_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Profession_Generic2Text",{"profession":itemName})));
            }
            if(m_window.hasOwnProperty("generic3_tf"))
            {
               addWidget(new ZwTextField(m_window["generic3_tf"],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_Profession_Generic3Text")));
            }
            if(m_window.hasOwnProperty("okay_bt"))
            {
               shareCallback = this.shareCallback;
               addWidget(new FarmAnimatedTextButton(m_window["okay_bt"],"Share",shareCallback));
            }
            if(m_window.hasOwnProperty("giftbox_mc"))
            {
               m_window["giftbox_mc"].visible = true;
            }
            if(m_window.hasOwnProperty("icon_mc"))
            {
               this.addWidget(new ObjectPreviewFrame(m_window.icon_mc,this.m_reward,null,[this.m_zoomingScale],null,"","",null,new Point(0,OFFSET_OPF_Y)));
            }
            if(Boolean(m_window.mc_RewardDialog) && Boolean(this.m_bgIcon))
            {
               m_window.addChildAt(this.m_bgIcon,m_window.getChildIndex(m_window.mc_RewardDialog));
            }
         }
      }
      
      public function onButtonClick(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event,this.m_animalName);
         }
         this.close();
      }
      
      override protected function onClose(event:Event) : void
      {
         if(this.m_callback != null)
         {
            this.m_callback(event,this.m_animalName);
         }
         super.onClose(event);
      }
      
      private function shareCallback(e:Event) : void
      {
         var fi:FarmItem = this.m_reward;
         var bundleData:Object = {
            "images":[{
               "href":"{SN_APP_URL}",
               "src":fi.icon
            }],
            "first_name":Global.player.firstName,
            "item":fi.friendlyTitle
         };
         GlobalEngine.socialNetwork.publishFeedStory("animal_university_2019_v2_share_Reward",bundleData,[],false,null);
         if(this.m_callback != null)
         {
            this.m_callback(e,this.m_animalName);
         }
         this.close();
         FarmStatsManager.count("animal_academy","reward_bragfeed",fi.friendlyTitle);
      }
   }
}


package Widgets.Windows.CaptureFeatures
{
   import Classes.CaptureFeatureItem;
   import Classes.util.ZLocUtils;
   import Managers.CaptureFeatureManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.CaptureFeatureBuilding.CaptureFeatureObjectPreviewFrame;
   import Widgets.Frames.CaptureFeatureBuilding.CaptureFeatureRewardFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   
   public class CaptureFeaturePopupWindow extends FarmWindow
   {
      
      public static const INSUFFICIENT_TREATS:String = "escaped";
      
      public static const CAPTURED:String = "captured";
      
      public static const APPEARED:String = "appeared";
      
      private var m_featureItem:CaptureFeatureItem;
      
      private var m_type:String;
      
      private const SWF_NAME:String = "assets/dialogs/FV_animal_GopherPopup.swf";
      
      private const CAPTURED_SWF_NAME:String = "assets/dialogs/FV_birdmigration_reward.swf";
      
      private var m_askForTreatsBtn:FarmAnimatedTextButton;
      
      private const PREVIEW_SCALE:Number = 2.5;
      
      protected var m_featureName:String;
      
      public function CaptureFeaturePopupWindow(featureName:String, featureItem:CaptureFeatureItem, type:String)
      {
         this.m_featureName = featureName;
         this.m_featureItem = featureItem;
         this.m_type = type;
         super(type == CAPTURED ? this.CAPTURED_SWF_NAME : this.SWF_NAME);
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"view");
      }
      
      override protected function postLoadComplete() : void
      {
         var title:String = null;
         var subTitle:String = null;
         var text:String = null;
         var bCapture:String = null;
         var bTreats:String = null;
         var bCaptureNow:String = null;
         var bShareRewards:String = null;
         var rewards:Array = null;
         var price:String = null;
         super.postLoadComplete();
         var frame:ZwFrame = addWidget(new ZwFrame(m_window.popupBox_mc)) as ZwFrame;
         var stringPrefix:String = CaptureFeatureManager.instance.getStringsPrefix(this.m_featureName);
         switch(this.m_type)
         {
            case INSUFFICIENT_TREATS:
               title = ZLocUtils.t("Dialogs",stringPrefix + "_Esc_Tr_Title");
               subTitle = ZLocUtils.t("Dialogs",stringPrefix + "_Esc_Tr_SubTi");
               text = ZLocUtils.t("Dialogs",stringPrefix + "_Esc_Tr_Desc");
               bTreats = ZLocUtils.t("Dialogs",stringPrefix + "_Esc_Tr_Btn");
               bCaptureNow = ZLocUtils.t("Dialogs",stringPrefix + "_Capture_Now");
               break;
            case CAPTURED:
               title = ZLocUtils.t("Dialogs","CaptureFeature_Cap_Title");
               subTitle = ZLocUtils.t("Dialogs",stringPrefix + "_Cap_Title");
               text = ZLocUtils.t("Dialogs",stringPrefix + "_Cap_SubTi",{"gopherName":this.m_featureItem.getItem().friendlyTitle});
               bShareRewards = ZLocUtils.t("Dialogs",stringPrefix + "_Cap_Btn");
               rewards = CaptureFeatureManager.instance.getCaptureItemRewardData(this.m_featureName,this.m_featureItem.getItemName());
               break;
            case APPEARED:
               title = ZLocUtils.t("Dialogs",stringPrefix + "_Appeared_Title");
               subTitle = ZLocUtils.t("Dialogs",stringPrefix + "_Appeared_SubTi",{"gopherName":this.m_featureItem.getItem().friendlyTitle});
               text = ZLocUtils.t("Dialogs",stringPrefix + "_Appeared_Desc");
               bCapture = ZLocUtils.t("Dialogs",stringPrefix + "_Appeared_Btn");
         }
         if(title)
         {
            addWidget(new ZwTextField(frame.element.title_tf,title));
         }
         if(subTitle)
         {
            addWidget(new ZwTextField(frame.element.generic_0_tf,subTitle));
         }
         if(text)
         {
            addWidget(new ZwTextField(frame.element.generic_1_tf,text));
         }
         if(bCapture)
         {
            addWidget(new FarmAnimatedTextButton(frame.element.capture_bt,bCapture,this.handleCaptureClicked));
         }
         if(bTreats)
         {
            this.m_askForTreatsBtn = new FarmAnimatedTextButton(frame.element.save_bt,bTreats,this.handleGetTreatsClicked);
            addWidget(this.m_askForTreatsBtn);
            this.m_askForTreatsBtn.enabled = CaptureFeatureManager.instance.canAskForTreats(this.m_featureName,"popup");
         }
         if(bCaptureNow)
         {
            price = "" + CaptureFeatureManager.instance.getGopherCapturePrice(this.m_featureName,this.m_featureItem.getItemName());
            addWidget(new FarmAnimatedCashButton(frame.element.accept_bt,bCaptureNow,price,this.handleCaptureNowClicked));
         }
         if(bShareRewards)
         {
            addWidget(new FarmAnimatedTextButton(frame.element.accept_bt,bShareRewards,this.handleShareRewardsClicked));
         }
         if(rewards)
         {
            addWidget(new CaptureFeatureRewardFrame(frame.element.reward_mc,rewards,50,50,true));
         }
         addWidget(new CaptureFeatureObjectPreviewFrame(frame.element.icon_mc,this.m_featureItem.getItem(),null,[this.PREVIEW_SCALE]));
         addWidget(new ZwButton(frame.element.close_bt,this.handleCloseClicked));
      }
      
      private function handleCaptureClicked(e:Event) : void
      {
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"capture");
         CaptureFeatureManager.instance.onFeatureInteraction(this.m_featureName,this.m_featureItem);
         this.m_featureItem.detach();
         this.close();
      }
      
      private function handleShareRewardsClicked(e:Event) : void
      {
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"share");
         CaptureFeatureManager.instance.askForTreats(this.m_featureName,"reward");
         CaptureFeatureManager.instance.postCapture(this.m_featureItem);
         this.m_featureItem.detach();
         this.close();
      }
      
      private function handleCloseClicked(e:Event) : void
      {
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"x");
         if(this.m_type == CaptureFeaturePopupWindow.CAPTURED)
         {
            CaptureFeatureManager.instance.postCapture(this.m_featureItem);
            this.m_featureItem.detach();
         }
         this.close();
      }
      
      private function handleGetTreatsClicked(e:Event) : void
      {
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"ask");
         CaptureFeatureManager.instance.askForTreats(this.m_featureName,"popup");
         if(this.m_askForTreatsBtn)
         {
            this.m_askForTreatsBtn.enabled = CaptureFeatureManager.instance.canAskForTreats(this.m_featureName,"popup");
         }
      }
      
      private function handleCaptureNowClicked(e:Event) : void
      {
         FarmStatsManager.count("dialog",CaptureFeatureManager.instance.getStatsPrefix(this.m_featureName) + "_dialog","popup",this.m_type,"pay_capture");
         var price:int = CaptureFeatureManager.instance.getGopherCapturePrice(this.m_featureName,this.m_featureItem.getItemName());
         if(Global.player.canBuyCash(price,true))
         {
            Global.player.cash -= price;
            CaptureFeatureManager.instance.captureGopher(this.m_featureName,this.m_featureItem,true);
            this.m_featureItem.detach();
            this.close();
         }
      }
   }
}


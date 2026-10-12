package Widgets.Windows
{
   import Classes.Animal;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.WanderingPirateManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.ObjectPreviewFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class WanderingPirateRewardWindow extends FarmWindow
   {
      
      private static const RARE_STRING:String = "rare";
      
      public static const STATE_FRONT_IDLE:String = "frt_idle";
      
      private static const OFFSET_OPF_Y:int = -30;
      
      private static const ICON_SIZE:int = 200;
      
      private var m_rewardTitle:ZwTextField;
      
      private var m_rewardSubTitle:ZwTextField;
      
      private var m_rewardItemName:String;
      
      private var m_icon:FarmIcon = null;
      
      private var m_rewardmc:MovieClip = null;
      
      private var m_rewardRarity:String;
      
      private var m_rewardWindowCloseCallback:Function;
      
      private var m_shareButton:FarmAnimatedTextButton;
      
      private var m_keyBoxNumber:int;
      
      private var m_titleTf:FarmTextField;
      
      private var m_shipPart:ZwWidget;
      
      private var m_shipPartText:ZwTextField;
      
      private var m_progressBarMc:ZwWidget;
      
      private var m_checkMark:ZwWidget;
      
      private var m_shouldShowFinalPop:Boolean = false;
      
      private var m_shouldShowMap:Boolean = false;
      
      private var m_Orb:MovieClip;
      
      private var m_OrbFill:MovieClip;
      
      private var m_icon1:ObjectPreviewFrame;
      
      private var m_objectPreviewFrame:ObjectPreviewFrame;
      
      private var m_iconPreview:FarmIcon;
      
      public function WanderingPirateRewardWindow(assetPath:String = "assets/dialogs/FV_WPReward.swf", keyBoxNumber:int = 0, rewardItem:Object = null, rewardWindowCloseCallback:Function = null, shouldShowMap:Boolean = false)
      {
         super(assetPath);
         if(rewardItem)
         {
            this.m_rewardItemName = rewardItem[WanderingPirateManager.NAME];
            this.m_rewardRarity = rewardItem[RARE_STRING];
            this.m_keyBoxNumber = keyBoxNumber;
            this.m_shouldShowMap = shouldShowMap;
         }
         this.m_rewardWindowCloseCallback = rewardWindowCloseCallback;
      }
      
      override protected function postLoadComplete() : void
      {
         var chestCategoryString:String = null;
         var itemName:String = null;
         var numItemsWon:int = 0;
         var grantedAll:Boolean = false;
         var mapsFinished:Number = NaN;
         var orbString:String = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            this.m_titleTf = addWidget(new FarmTextField(m_window.title_tf as TextField,ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_rewardtitle"),true)) as FarmTextField;
         }
         if(m_window.hasOwnProperty("shipPart_mc"))
         {
            this.m_shipPart = addWidget(new ZwWidget(m_window.shipPart_mc),false) as ZwWidget;
            if(Boolean(this.m_shipPart) && this.m_shipPart.element.hasOwnProperty("shipPart_tf"))
            {
               this.m_shipPartText = addWidget(new FarmTextField(this.m_shipPart.element.shipPart_tf as TextField,ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_mapPart"),true)) as FarmTextField;
               this.m_shipPart.visible = this.m_shouldShowMap;
            }
         }
         var rewardFrameString:String = "rewardPoint_mc_" + this.m_keyBoxNumber;
         var slotFrameString:String = "slot_" + this.m_keyBoxNumber + "_mc";
         this.m_rewardmc = m_window[rewardFrameString] as MovieClip;
         if(this.m_rewardmc)
         {
            this.m_rewardmc.visible = true;
         }
         var giftItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByName(this.m_rewardItemName);
         if(this.m_rewardmc.hasOwnProperty("item_icon_mc") && giftItem.getImageByName("frt_idle") != null)
         {
            this.m_objectPreviewFrame = new ObjectPreviewFrame(this.m_rewardmc.item_icon_mc.objectPreview_mc,giftItem,null,null,null,Animal.STATE_FRONT_IDLE);
            (this.m_objectPreviewFrame.element as MovieClip).filters = [];
            addWidget(this.m_objectPreviewFrame,true);
         }
         else if(this.m_rewardmc.item_icon_mc.hasOwnProperty("icon_mc"))
         {
            this.m_iconPreview = new FarmIcon(this.m_rewardmc.item_icon_mc.icon_mc,giftItem.getImageByName(FarmItem.ICON_FEED));
            addWidget(this.m_iconPreview,true);
         }
         if(giftItem)
         {
            chestCategoryString = ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_chest_" + this.m_keyBoxNumber);
            itemName = ZLocUtils.tk_pk_asTitle(giftItem.friendlyName);
         }
         var zLocObj:Object = {
            "chestCategory":chestCategoryString,
            "itemName":itemName
         };
         if(Boolean(this.m_rewardmc) && Boolean(this.m_rewardmc.hasOwnProperty("textAni_mc")) && Boolean(this.m_rewardmc.textAni_mc) && Boolean(this.m_rewardmc.textAni_mc.subTitle_txt))
         {
            addWidget(this.m_rewardTitle = new FarmTextField(this.m_rewardmc.textAni_mc.subTitle_txt,ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_rewardTitle",zLocObj)),true) as FarmTextField;
         }
         if(Boolean(this.m_rewardmc) && Boolean(this.m_rewardmc.hasOwnProperty("textAni_mc")) && Boolean(this.m_rewardmc.textAni_mc) && Boolean(this.m_rewardmc.textAni_mc.subDis_txt))
         {
            addWidget(this.m_rewardSubTitle = new FarmTextField(this.m_rewardmc.textAni_mc.subDis_txt,ZLocUtils.t("Dialogs",WanderingPirateManager.FEATURE_NAME + "_rewardSubTitle")),true) as FarmTextField;
         }
         if(Boolean(this.m_rewardmc) && Boolean(this.m_rewardmc[slotFrameString]) && Boolean(this.m_rewardmc[slotFrameString].completeIcon_mc))
         {
            this.m_checkMark = addWidget(new ZwWidget(this.m_rewardmc[slotFrameString].completeIcon_mc),false) as ZwWidget;
            if(this.m_checkMark)
            {
               this.m_checkMark.visible = false;
            }
         }
         if(this.m_rewardmc)
         {
            this.m_rewardmc.play();
         }
         if(Boolean(this.m_rewardmc) && Boolean(this.m_rewardmc[slotFrameString]) && Boolean(this.m_rewardmc[slotFrameString].progressBar_mc))
         {
            this.m_progressBarMc = addWidget(new ZwWidget(this.m_rewardmc[slotFrameString].progressBar_mc),true) as ZwWidget;
            numItemsWon = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).getLength(this.m_keyBoxNumber);
            grantedAll = WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).hasUserFinished();
            if(this.m_progressBarMc)
            {
               this.m_progressBarMc.visible = true;
               switch(numItemsWon)
               {
                  case 1:
                     this.m_progressBarMc.element.gotoAndPlay(2);
                     break;
                  case 2:
                     this.m_progressBarMc.element.gotoAndPlay(16);
                     break;
                  case 3:
                     this.m_progressBarMc.element.gotoAndPlay(31);
                     break;
                  case 4:
                     this.m_progressBarMc.element.gotoAndPlay(46);
                     if(Boolean(this.m_checkMark) && !grantedAll)
                     {
                        this.m_checkMark.visible = true;
                     }
               }
            }
         }
         if(m_window.hasOwnProperty("share_bt"))
         {
            addWidget(this.m_shareButton = new FarmAnimatedTextButton(m_window.share_bt,"Share!",this.onShareButtonClicked));
         }
         if(this.m_shouldShowMap)
         {
            if(m_window.hasOwnProperty("orbFilled_mc"))
            {
               if(m_window.hasOwnProperty("orbFilled_mc"))
               {
                  this.m_Orb = m_window.orbFilled_mc;
                  this.m_Orb.visible = true;
                  mapsFinished = WanderingPirateManager.getInstance().getMapsFinished();
                  if(mapsFinished > WanderingPirateManager.NUM_OF_CASES)
                  {
                     mapsFinished = WanderingPirateManager.NUM_OF_CASES;
                  }
                  orbString = "orb_" + mapsFinished + "_mc";
                  (this.m_Orb["orb_1_mc"] as MovieClip).visible = false;
                  (this.m_Orb["orb_2_mc"] as MovieClip).visible = false;
                  (this.m_Orb["orb_3_mc"] as MovieClip).visible = false;
                  (this.m_Orb["orb_4_mc"] as MovieClip).visible = false;
                  this.m_OrbFill = this.m_Orb[orbString] as MovieClip;
                  if(this.m_OrbFill)
                  {
                     this.m_OrbFill.visible = true;
                     this.m_OrbFill.gotoAndPlay(1);
                  }
               }
            }
         }
      }
      
      public function onShareButtonClicked(event:Event = null) : void
      {
         this.m_shareButton.enabled = false;
         WanderingPirateManager.getInstance(WanderingPirateManager.FEATURE_NAME).onBragFeed(this.m_rewardItemName);
         this.close();
      }
      
      override public function close() : void
      {
         super.close();
         this.m_rewardWindowCloseCallback(this.m_shouldShowMap);
      }
      
      override protected function release() : void
      {
         this.m_rewardmc = null;
         this.m_icon = null;
         this.m_rewardTitle = null;
         this.m_rewardSubTitle = null;
         this.m_shareButton = null;
         if(this.m_checkMark)
         {
            this.m_checkMark = null;
         }
         if(this.m_progressBarMc)
         {
            this.m_progressBarMc = null;
         }
         super.release();
      }
   }
}


package Display
{
   import Classes.HaitiBackpack;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Engine.Managers.LoadingManager;
   import Engine.Utilities;
   import Events.GenericPopupEvent;
   import GameMode.GMCreditsBuildingItemPlace;
   import Managers.FarmStatsManager;
   import com.greensock.TweenLite;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class HaitiBackpackDialog extends RewardCreditsBuildingDialog
   {
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_Haiti.swf";
      
      private static const LOCKED_ITEM_ICON_URL:String = "assets/decorations/haiti_locked_icon.png";
      
      private static const ABOUT_IMAGE_PATH:String = "assets/dialogs/haiti/Haiti_";
      
      private static const ABOUT_IMAGE_SUFFIX:String = ".jpg";
      
      private static const IMAGE_COUNT:int = 5;
      
      private static const IMAGE_DELAY:int = 5;
      
      private static const IMAGE_TWEEN_LENGTH:Number = 0.4;
      
      private static const URL_ZYNGA_ORG:String = "http://www.zynga.org/initiatives/haiti.php";
      
      protected static const MODE_SCHOOL:uint = 2;
      
      protected var m_itemToBuy:FarmItem = null;
      
      private var m_imageContainerArray:Array = new Array();
      
      private var m_fullscreenImagesArray:Array = new Array();
      
      private var m_tabbedImagesArray:Array = new Array();
      
      private var m_canRotate:Boolean;
      
      private var m_returnToFarmBtn:GenericButton;
      
      private var m_buySuppliesBtn:GenericButton;
      
      private var m_aboutSchoolBtn:GenericButton;
      
      private var m_progressButton:GenericButton;
      
      private var m_comparisonButton:GenericButton;
      
      private var m_rotationCount:int;
      
      private var m_introPanel:MovieClip;
      
      public function HaitiBackpackDialog(haitiBackpack:HaitiBackpack, showWhatIsThisOnLoad:Boolean = false)
      {
         super(haitiBackpack,"HaitiBackpack",DIALOG_ASSET,showWhatIsThisOnLoad);
      }
      
      override protected function onLoadComplete() : void
      {
         var askCreditsButton:MovieClip = null;
         super.onLoadComplete();
         this.m_introPanel = m_window.introPanel_mc;
         this.m_introPanel.visible = false;
         m_window.haiti_mc.visible = false;
         m_window.haiti_mc.copy_tf.text = ZLocUtils.t("Dialogs","HaitiBackpack_AboutCopy");
         m_window.title_tf.text = ZLocUtils.t("Dialogs","HaitiBackpack_SubTitle");
         this.loadHaitiImages();
         if(!Global.player.getSeenFlag("HaitiBackPackFullDialog"))
         {
            this.setAboutSchoolFullDialogView();
         }
         else
         {
            this.addButtons();
         }
         if(!isAskSendEnabled())
         {
            askCreditsButton = this.getAskForCreditsButton();
            if(askCreditsButton)
            {
               askCreditsButton.visible = false;
            }
         }
      }
      
      private function loadHaitiImages() : void
      {
         var random:int = 0;
         var file:String = null;
         var path:String = null;
         var mc:MovieClip = null;
         var fileNameArray:Array = new Array();
         fileNameArray = ["01","02","03","04","05","06","07","08","09","10","11"];
         var randomArray:Array = new Array();
         for(var randomIdx:int = 0; randomIdx < IMAGE_COUNT; randomIdx++)
         {
            random = Math.floor(Utilities.randBetween(0,fileNameArray.length - 1)) as int;
            file = fileNameArray[random];
            randomArray.push(file);
            fileNameArray.splice(random,1);
         }
         for(var idx:int = 0; idx < IMAGE_COUNT; idx++)
         {
            path = Global.getAssetURL(ABOUT_IMAGE_PATH + randomArray[idx] + ABOUT_IMAGE_SUFFIX);
            mc = new MovieClip();
            this.m_imageContainerArray.push(mc);
            this.loadImages(path,mc);
         }
      }
      
      private function setAboutSchoolFullDialogView() : void
      {
         this.m_introPanel.visible = true;
         Global.player.setSeenFlag("HaitiBackPackFullDialog");
         this.m_introPanel.copy_tf.text = ZLocUtils.t("Dialogs","HaitiBackpack_AboutCopy");
         this.m_introPanel.copy2_tf.text = ZLocUtils.t("Dialogs","HaitiBackpack_AboutCopy2");
         var genBtn:GenericButton = new GenericButton(this.m_introPanel.okay_bt,this.onIntroOkClick);
         this.attachImagesToContainers();
         this.m_canRotate = true;
         this.startFade(this.m_introPanel);
      }
      
      private function attachImagesToContainers() : void
      {
         var mc:MovieClip = null;
         var mc2:MovieClip = null;
         for(var idx:int = 0; idx < IMAGE_COUNT; idx++)
         {
            mc = this.m_introPanel.photo1_mc.addChild(this.m_imageContainerArray[idx]);
            this.m_fullscreenImagesArray.push(mc);
            mc2 = m_window.haiti_mc.photo1_mc.addChild(this.m_imageContainerArray[idx]);
            this.m_tabbedImagesArray.push(mc2);
         }
      }
      
      private function startFade(container:MovieClip) : void
      {
         Utilities.removeAllChildren(container.photo1_mc);
         for(var idx:int = 0; idx < IMAGE_COUNT; idx++)
         {
            container.photo1_mc.addChild(this.m_imageContainerArray[idx]);
         }
         this.m_rotationCount = IMAGE_COUNT;
         var mc:MovieClip = container.photo1_mc.getChildAt(this.m_rotationCount - 1) as MovieClip;
         TweenLite.to(mc,IMAGE_TWEEN_LENGTH,{
            "delay":IMAGE_DELAY,
            "alpha":0,
            "onComplete":this.fadeNextImg,
            "onCompleteParams":[container]
         });
      }
      
      private function fadeNextImg(container:MovieClip) : void
      {
         var mc:MovieClip = null;
         if(this.m_canRotate)
         {
            --this.m_rotationCount;
            if(this.m_rotationCount == 1)
            {
               this.m_rotationCount = IMAGE_COUNT + 1;
               this.fadeUpLastImage(container);
            }
            else
            {
               mc = container.photo1_mc.getChildAt(this.m_rotationCount - 1) as MovieClip;
               TweenLite.to(mc,IMAGE_TWEEN_LENGTH,{
                  "delay":IMAGE_DELAY,
                  "alpha":0,
                  "onComplete":this.fadeNextImg,
                  "onCompleteParams":[container]
               });
            }
         }
      }
      
      private function fadeUpLastImage(container:MovieClip) : void
      {
         var mc:MovieClip = container.photo1_mc.getChildAt(IMAGE_COUNT - 1) as MovieClip;
         TweenLite.to(mc,IMAGE_TWEEN_LENGTH,{
            "delay":IMAGE_DELAY,
            "alpha":1,
            "onComplete":this.setRemainingImagesToFullAlpha,
            "onCompleteParams":[container]
         });
      }
      
      private function setRemainingImagesToFullAlpha(container:MovieClip) : void
      {
         var mc:MovieClip = null;
         for(var idx:int = 0; idx < IMAGE_COUNT - 1; idx++)
         {
            mc = container.photo1_mc.getChildAt(idx) as MovieClip;
            mc.alpha = 1;
         }
         this.fadeNextImg(container);
      }
      
      private function onIntroOkClick(event:MouseEvent) : void
      {
         this.addButtons();
         this.m_canRotate = false;
         this.m_introPanel.visible = false;
      }
      
      private function onZyngaClick(event:MouseEvent) : void
      {
         GlobalEngine.socialNetwork.redirect(URL_ZYNGA_ORG,null,"_blank",false);
      }
      
      private function loadImages(path:String, container:MovieClip) : void
      {
         var img:Loader = null;
         img = LoadingManager.load(path,function(event:Event):void
         {
            var dispObj:* = img.content;
            container.addChild(dispObj);
            container.visible = true;
         });
      }
      
      private function addButtons() : void
      {
         this.m_returnToFarmBtn = new GenericButton(m_window.btn_return,onClose);
         this.m_buySuppliesBtn = new GenericButton(m_window.meter_mc.btn_buySupplies,this.onBuyClick);
         this.m_aboutSchoolBtn = new GenericButton(m_window.school_bt,this.onAboutSchoolClick);
         this.m_aboutSchoolBtn.text = ZLocUtils.t("Dialogs","HaitiBackpack_About");
         var zyngaBtn:GenericButton = new GenericButton(m_window.haiti_mc.link_mc,this.onZyngaClick);
         this.m_progressButton = m_buttons[PROGRESS_BT] as GenericButton;
         this.m_comparisonButton = m_buttons[COMPARISON_BT] as GenericButton;
      }
      
      private function onBuyClick(event:MouseEvent = null) : void
      {
         if(this.m_shown)
         {
            this.hide();
         }
         FarmStatsManager.count(this.getAskForCreditsCounter(),"purchase_supplies");
         this.m_itemToBuy = Global.farmGameSettingsManager.getFarmItemByName(HaitiBackpack.HAITI_BACKPACK_5);
         var messageText:String = ZLocUtils.t("Dialogs","ConstructionBuilding_BuyConfirmation",{
            "item":ZLocUtils.tk_pk(this.m_itemToBuy.friendlyName),
            "cashQuantity":this.m_itemToBuy.cash
         });
         UI.displayPopup(new GenericPopup(messageText,GenericPopup.TYPE_ACCEPTCANCEL,this.onBuyConfirmation),false);
         onClose(event);
      }
      
      private function onBuyConfirmation(evt:GenericPopupEvent) : void
      {
         if(evt.button == GenericPopup.ACCEPT && this.m_itemToBuy != null)
         {
            FarmStatsManager.count(this.getAskForCreditsCounter(),"purchase_supplies","accept");
            if(Global.player.canBuyCash(this.m_itemToBuy.cash,false))
            {
               Global.world.addGameMode(new GMCreditsBuildingItemPlace(this.m_itemToBuy.name,false),false);
            }
            else
            {
               UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_MARKET_CASH,"impulseBuyPopup",this.m_itemToBuy.cash,this.m_itemToBuy.type);
            }
         }
         close();
      }
      
      override protected function getAskForCreditsFeatureName() : String
      {
         return HaitiBackpack.ASK_FOR_CREDITS_FEATURE_NAME;
      }
      
      override protected function getAskForCreditsCounter() : String
      {
         return "haitibackpack";
      }
      
      override protected function getAskForCreditsCounterKingdom() : String
      {
         return "request_more_supplies";
      }
      
      override protected function getDialogSideIconUrl() : String
      {
         return HaitiBackpack.DIALOG_SIDE_ICON;
      }
      
      override protected function getLockedItemIconUrl() : String
      {
         return LOCKED_ITEM_ICON_URL;
      }
      
      override protected function getBuildingCreditsXml() : XML
      {
         return Global.farmGameSettingsManager.getBuildingCreditsXml("haitiBackpack");
      }
      
      override protected function getAskSendDisableDate() : String
      {
         return Global.farmGameSettingsManager.getString("haitiBackpackAskSendDisableDate");
      }
      
      override protected function onHowDoesThisWorkClick(event:Event = null) : void
      {
         var msg:String = null;
         var genericPopup:GenericPopup = null;
         if(!m_howDoesThisWorkPopup)
         {
            msg = ZLocUtils.t("Dialogs","HaitiBackpack_HowDoesThisWork");
            genericPopup = new GenericPopup(msg,GenericPopup.TYPE_OK,this.onHowDoesThisWorkClose,GenericPopup.GENERIC_ASSET,"",true);
            genericPopup.setAcceptTextName("Okay");
            m_howDoesThisWorkPopup = genericPopup;
            UI.displayPopup(m_howDoesThisWorkPopup,false,m_buildingClassName + "_howDoesThisWorkPopup",true);
         }
      }
      
      private function onAboutSchoolClick(event:MouseEvent) : void
      {
         m_currentMode = MODE_SCHOOL;
         this.adjustFrameAppearance();
      }
      
      override protected function adjustFrameAppearance() : void
      {
         if(m_currentMode == MODE_PROGRESS)
         {
            setProgressVisibility(true);
            setComparisonVisibility(false);
            if(this.m_progressButton)
            {
               this.m_progressButton.state = GenericButton.HITSTATE;
            }
            if(this.m_comparisonButton)
            {
               this.m_comparisonButton.state = GenericButton.UPSTATE;
            }
            if(this.m_aboutSchoolBtn)
            {
               this.setAboutVisibility(false);
               this.m_aboutSchoolBtn.state = GenericButton.UPSTATE;
            }
            FarmStatsManager.count(this.getAskForCreditsCounter(),"open_rewards");
            this.m_canRotate = false;
            refreshCreditMeter();
         }
         else if(m_currentMode == MODE_COMPARISON)
         {
            setProgressVisibility(false);
            setComparisonVisibility(true);
            if(this.m_progressButton)
            {
               this.m_progressButton.state = GenericButton.UPSTATE;
            }
            if(this.m_comparisonButton)
            {
               this.m_comparisonButton.state = GenericButton.HITSTATE;
            }
            if(this.m_aboutSchoolBtn)
            {
               this.setAboutVisibility(false);
               this.m_aboutSchoolBtn.state = GenericButton.UPSTATE;
            }
            FarmStatsManager.count(this.getAskForCreditsCounter(),"open_comparison");
            this.m_canRotate = false;
            fixArrows();
         }
         else if(m_currentMode == MODE_SCHOOL)
         {
            setProgressVisibility(false);
            setComparisonVisibility(false);
            if(this.m_progressButton)
            {
               this.m_progressButton.state = GenericButton.UPSTATE;
            }
            if(this.m_comparisonButton)
            {
               this.m_comparisonButton.state = GenericButton.UPSTATE;
            }
            if(this.m_aboutSchoolBtn)
            {
               this.setAboutVisibility(true);
               this.m_aboutSchoolBtn.state = GenericButton.HITSTATE;
            }
            FarmStatsManager.count(this.getAskForCreditsCounter(),"open_school");
            this.m_canRotate = true;
            this.startFade(m_window.haiti_mc);
         }
      }
      
      private function setAboutVisibility(vis:Boolean) : void
      {
         m_window.haiti_mc.visible = vis;
      }
      
      override protected function getAskForCreditsButton() : MovieClip
      {
         return m_window.askForMore_mc;
      }
      
      override protected function onHowDoesThisWorkClose(event:GenericPopupEvent) : void
      {
         m_howDoesThisWorkPopup = null;
      }
      
      override protected function disableAskForCreditsButton() : void
      {
         super.disableAskForCreditsButton();
      }
      
      override protected function getMeterStack() : MovieClip
      {
         return m_window.meter_mc.stack_mc as MovieClip;
      }
      
      override protected function getCreditMeter() : MovieClip
      {
         return m_window.meter_mc as MovieClip;
      }
   }
}


package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Managers.DragonBreedingConfigManager;
   import Managers.DragonBreedingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DragonBreedingCongratsWindow extends FarmWindow
   {
      
      public static const NO_VISITING_DRAGON:int = 0;
      
      public static const MALE_VISITING_DRAGON:int = 1;
      
      public static const FEMALE_VISITING_DRAGON:int = 2;
      
      public static const BOTH_VISITING_DRAGON:int = 3;
      
      private const DEFAULT_ASSET:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_Share.swf";
      
      private const TITLE_TF:String = "title_tf";
      
      private const DESC_TF:String = "description_tf";
      
      private const NAME_TF:String = "dragonname_tf";
      
      private const INFO_TF:String = "senddragon_tf";
      
      private const ICON_BABY:String = "babydragon_mc";
      
      private const ICON_MALE:String = "parenticon_male_mc";
      
      private const ICON_FEMALE:String = "parenticon_female_mc";
      
      private const OR_MC:String = "or_mc";
      
      private const SHARE_BTN_MALE:String = "send_bt_0";
      
      private const SHARE_BTN_FEMALE:String = "send_bt_1";
      
      private const SHARE_BTN:String = "send_bt_2";
      
      private const NPC_MC:String = "npc_mc";
      
      private var m_featureName:String;
      
      private var m_maleDragonCode:String;
      
      private var m_femaleDragonCode:String;
      
      private var m_offspringIndex:Number;
      
      private var m_titleTf:ZwTextField;
      
      private var m_bodyTf:ZwTextField;
      
      private var m_info_tf:ZwTextField;
      
      private var m_dragonoffspring_tf:ZwTextField;
      
      private var m_icon_baby:FarmIcon;
      
      private var m_icon_0:FarmIcon;
      
      private var m_icon_1:FarmIcon;
      
      private var m_shareBtn_0:FarmAnimatedTextButton;
      
      private var m_shareBtn_1:FarmAnimatedTextButton;
      
      private var m_shareBtn_2:FarmAnimatedTextButton;
      
      private var m_dragonBreedinWindow:DragonBreedingWindow;
      
      private var m_visitingDragon:int;
      
      private var m_npc_mc:MovieClip;
      
      private var m_maleVdIcon:MovieClip;
      
      private var m_femaleVdIcon:MovieClip;
      
      public function DragonBreedingCongratsWindow(featureName:String, maleDragonCode:String, femaleDragonCode:String, offspringIndex:Number, visitingDragon:int, dragonBreedingWindow:DragonBreedingWindow = null, windowAssetRelUrl:String = "assets/dialogs/DragonBreeding/FV_DragonBreeding_Share.swf")
      {
         this.m_featureName = featureName;
         this.m_maleDragonCode = maleDragonCode;
         this.m_femaleDragonCode = femaleDragonCode;
         this.m_offspringIndex = offspringIndex;
         this.m_dragonBreedinWindow = dragonBreedingWindow;
         this.m_visitingDragon = visitingDragon;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         var orMc:MovieClip = null;
         var offspring:Object = null;
         var offspringItem:FarmItem = null;
         super.postLoadComplete();
         var maleItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_maleDragonCode);
         var maleFriendlyName:String = maleItem.friendlyTitle;
         var femaleItem:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_femaleDragonCode);
         var femaleFriendlyName:String = femaleItem.friendlyTitle;
         var babyImageURL:String = DragonBreedingManager.getInstance(this.m_featureName).getImageForOffspring(maleItem.name,femaleItem.name,this.m_offspringIndex);
         if(m_window.hasOwnProperty(this.TITLE_TF))
         {
            this.m_titleTf = addWidget(new ZwTextField(m_window[this.TITLE_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_title")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.DESC_TF))
         {
            this.m_bodyTf = addWidget(new ZwTextField(m_window[this.DESC_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_desc",{
               "maleName":maleFriendlyName,
               "femaleName":femaleFriendlyName
            })),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty(this.INFO_TF))
         {
            this.m_info_tf = addWidget(new ZwTextField(m_window[this.INFO_TF],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_info")),true) as ZwTextField;
         }
         if(m_window.hasOwnProperty("visiting01_mc"))
         {
            this.m_maleVdIcon = m_window["visiting01_mc"] as MovieClip;
            this.m_maleVdIcon.visible = false;
         }
         if(m_window.hasOwnProperty("visiting02_mc"))
         {
            this.m_femaleVdIcon = m_window["visiting02_mc"] as MovieClip;
            this.m_femaleVdIcon.visible = false;
         }
         if(m_window.hasOwnProperty(this.OR_MC))
         {
            orMc = m_window[this.OR_MC] as MovieClip;
            orMc.visible = true;
         }
         if(m_window.hasOwnProperty(this.SHARE_BTN_MALE))
         {
            this.m_shareBtn_0 = addWidget(new FarmAnimatedTextButton(m_window[this.SHARE_BTN_MALE],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_ShareBtnText",{"itemName":maleFriendlyName}),this.onShareMaleDragon),true) as FarmAnimatedTextButton;
            if(this.m_visitingDragon == MALE_VISITING_DRAGON || this.m_visitingDragon == BOTH_VISITING_DRAGON)
            {
               this.m_shareBtn_0.visible = false;
               if(this.m_maleVdIcon)
               {
                  this.m_maleVdIcon.visible = true;
                  if(m_window.hasOwnProperty("visiting01_tf"))
                  {
                     addWidget(new ZwTextField(m_window["visiting01_tf"],maleFriendlyName),true);
                  }
               }
               orMc.visible = false;
            }
         }
         if(m_window.hasOwnProperty(this.SHARE_BTN_FEMALE))
         {
            this.m_shareBtn_1 = addWidget(new FarmAnimatedTextButton(m_window[this.SHARE_BTN_FEMALE],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_ShareBtnText",{"itemName":femaleFriendlyName}),this.onShareFemaleDragon),true) as FarmAnimatedTextButton;
            if(this.m_visitingDragon == FEMALE_VISITING_DRAGON || this.m_visitingDragon == BOTH_VISITING_DRAGON)
            {
               this.m_shareBtn_1.visible = false;
               orMc.visible = false;
               if(this.m_femaleVdIcon)
               {
                  this.m_femaleVdIcon.visible = true;
                  if(m_window.hasOwnProperty("visiting02_tf"))
                  {
                     addWidget(new ZwTextField(m_window["visiting02_tf"],femaleFriendlyName),true);
                  }
               }
            }
         }
         if(m_window.hasOwnProperty(this.ICON_MALE))
         {
            this.m_icon_0 = addWidget(new FarmIcon(m_window[this.ICON_MALE],maleItem.iconUrl)) as FarmIcon;
         }
         if(m_window.hasOwnProperty(this.ICON_FEMALE))
         {
            this.m_icon_1 = addWidget(new FarmIcon(m_window[this.ICON_FEMALE],femaleItem.iconUrl)) as FarmIcon;
         }
         if(m_window.hasOwnProperty(this.ICON_BABY))
         {
            this.m_icon_baby = addWidget(new FarmIcon(m_window[this.ICON_BABY],babyImageURL)) as FarmIcon;
         }
         if(m_window.hasOwnProperty(this.NPC_MC))
         {
            this.m_npc_mc = m_window[this.NPC_MC];
         }
         if(m_window.hasOwnProperty(this.NAME_TF))
         {
            offspring = DragonBreedingManager.getInstance(this.m_featureName).getOffspringForCouple(maleItem.name,femaleItem.name,this.m_offspringIndex.toString());
            offspringItem = Global.farmGameSettingsManager.getFarmItemByCode(offspring[DragonBreedingConfigManager.BODY_DATA_KEY]);
            if(offspringItem)
            {
               this.m_dragonoffspring_tf = addWidget(new ZwTextField(m_window[this.NAME_TF],offspringItem.friendlyTitle),true) as ZwTextField;
            }
         }
         if(this.m_visitingDragon != NO_VISITING_DRAGON)
         {
            this.m_info_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_info2");
            if(this.m_visitingDragon == BOTH_VISITING_DRAGON)
            {
               this.m_info_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_CongratsWindow_info3");
               if(m_window.hasOwnProperty(this.SHARE_BTN))
               {
                  this.m_shareBtn_2 = addWidget(new FarmAnimatedTextButton(m_window[this.SHARE_BTN],ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + "_LevelUpWindow_ShareBtnText"),this.onShare),true) as FarmAnimatedTextButton;
               }
            }
         }
         if(Boolean(this.m_dragonBreedinWindow) && this.m_dragonBreedinWindow.isInTutorial())
         {
            if(this.m_dragonBreedinWindow.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_8))
            {
               this.m_dragonBreedinWindow.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_9);
            }
            if(this.m_npc_mc)
            {
               this.m_npc_mc.visible = false;
            }
         }
         else if(this.m_npc_mc)
         {
            this.m_npc_mc.visible = true;
         }
      }
      
      private function onShareMaleDragon(e:Event) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).postFeedForVisitingDragon(this.m_maleDragonCode);
         this.close();
      }
      
      private function onShareFemaleDragon(e:Event) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).postFeedForVisitingDragon(this.m_femaleDragonCode);
         this.close();
      }
      
      override public function close() : void
      {
         if(this.m_dragonBreedinWindow)
         {
            this.m_dragonBreedinWindow.untintWindow();
            this.m_dragonBreedinWindow.enableInput = true;
            UI.stopPopups(false);
            if(this.m_dragonBreedinWindow.isInTutorial() && this.m_dragonBreedinWindow.assertTutorialIndexIs(DragonBreedingWindow.TUTORIAL_STEP_9))
            {
               this.m_dragonBreedinWindow.displayTutorialMessage(DragonBreedingWindow.TUTORIAL_STEP_10);
               DragonBreedingManager.getInstance(this.m_featureName).completeTutorialAfterCongratsWindow();
            }
         }
         super.close();
      }
      
      private function onShare(e:Event) : void
      {
         DragonBreedingManager.getInstance(this.m_featureName).shareBragFeed(DragonBreedingManager.BRAG_FEED_UNLOCK_LEVEL);
         this.close();
      }
   }
}


package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.Constants.WorldsConstants;
   import Classes.MOTD.ExpansionEarlyAccessMotdHandler;
   import Classes.ZItem.ExpansionAccess;
   import Classes.ZItem.ExpansionData;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUDSkinConfig;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Events.GenericPopupEvent;
   import Managers.FarmStatsManager;
   import Managers.FreezeManager;
   import Managers.WorldManager;
   import Managers.WorldSeasonsManager;
   import Transactions.TExpansionWorldAccess;
   import Transactions.TSaveOptions;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Frames.TravelDialogSmallFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import com.adobe.utils.ArrayUtil;
   import com.troyer.widget.controller.CheckBoxController;
   import flash.events.Event;
   
   public class TravelWindow extends FarmWindow
   {
      
      public static const TRAVEL_WINDOW_SORTING_KEY:String = "travelWindowSorting";
      
      private static const DIALOG_ASSET:String = "assets/dialogs/FV_travelDialog.swf";
      
      private static const DIALOG_ASSET_V2:String = "assets/dialogs/FV_travelDialog_v2.swf";
      
      private static const DIALOG_ASSET_V3:String = "assets/dialogs/FV_travelDialog_v3.swf";
      
      private static const DIALOG_ASSET_V4:String = "assets/dialogs/FV_travelDialog_v4.swf";
      
      private static const TUTORIAL_EA_URL:String = "assets/dialogs/Japan/FV_xjp_EA_InfoFTUE.swf";
      
      private static const SHOW_ONE_WORLD_TO_TRAVEL:Number = 1;
      
      private static const SHOW_TWO_WORLD_TO_TRAVEL:Number = 2;
      
      private static const SHOW_THREE_WORLD_TO_TRAVEL:Number = 3;
      
      private static const SHOW_FOUR_WORLD_TO_TRAVEL:Number = 4;
      
      private static const LARGE_FRAME_ICON_WIDTH:Number = 702;
      
      private static const LARGE_FRAME_ICON_HEIGHT:Number = 251;
      
      private var m_selected:Boolean;
      
      private var m_shouldFreezeFarm:Boolean;
      
      private var m_travelLargeFrameIconUrl:String;
      
      private var m_assetPath:String;
      
      private var m_travelClip:ZwFrame;
      
      private var m_largeBankgroundImg:FarmIcon;
      
      private var m_travel_slot_1:ZwBaseWidget;
      
      private var m_travel_slot_2:ZwBaseWidget;
      
      private var m_travel_slot_3:ZwBaseWidget;
      
      private var m_travel_slot_4:ZwBaseWidget;
      
      private var m_travelShouldFreezeWorld:ZwBaseWidget;
      
      private var m_travelShouldFreezeWorldCheck:ZwBaseWidget;
      
      private var m_travelShouldSortWorldRelease:ZwBaseWidget;
      
      private var m_travelShouldSortWorldReleaseCheck:ZwBaseWidget;
      
      private var m_travelShouldSortWorldLastVisit:ZwBaseWidget;
      
      private var m_travelShouldSortWorldLastVisitCheck:ZwBaseWidget;
      
      private var m_travelShouldFreezeWorldText:FarmTextField;
      
      private var m_travelFreezeDesciption:FarmTextField;
      
      private var m_travelSortDescription:FarmTextField;
      
      private var m_arrowLeft:FarmButton;
      
      private var m_arrowRight:FarmButton;
      
      private var m_travelSmallFrame:TravelDialogSmallFrame;
      
      private var m_travelSmallIconData:Array;
      
      private var m_pauseToggle:CheckBoxController;
      
      private var m_latestUnlockedExpansionType:String;
      
      private var m_availableTravelWorlds:Array;
      
      private var m_availableTravelWorldsCopy:Array;
      
      private var m_numTravelOptions:Number;
      
      private var m_worldTypeToHighlight:String;
      
      private var m_travelSmallIconStartIndex:Number;
      
      private var m_travelSmallTotalAvailableSlots:Number;
      
      private var m_earlyAccessExpansionWorld:String;
      
      private var m_isSeason2EarlyAccess:Boolean = false;
      
      public function TravelWindow()
      {
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_WINDOW_SORTING_PREFERENCE) == 1)
         {
            this.m_assetPath = DIALOG_ASSET_V4;
         }
         else
         {
            this.m_assetPath = DIALOG_ASSET;
         }
         super(this.m_assetPath);
      }
      
      override protected function postLoadComplete() : void
      {
         var numSmallSlots:Number = NaN;
         var showPaging:Boolean = false;
         var displayEAIcon:Boolean = false;
         var callback:Function = null;
         var canShowHelpButton:Boolean = false;
         var callbackHelpButton:Function = null;
         var largeFrme_mc:FarmAnimatedButton = null;
         var helpButton:FarmAnimatedButton = null;
         var iconType:String = null;
         var assetUrl:String = null;
         var largeIconType:String = null;
         var icon:FarmIcon = null;
         var btnPanelVisible:Boolean = false;
         var travelFreezeWidget:ZwBaseWidget = null;
         var pauseText:String = null;
         var travelSortWidgetRelease:ZwBaseWidget = null;
         var sortReleaseText:String = null;
         var travelSortWidgetLastVisit:ZwBaseWidget = null;
         var sortLastVisitText:String = null;
         var access:ExpansionAccess = null;
         var daysLeft:int = 0;
         this.setUpInitialFrameData();
         var mainWidgetName:String = "slots" + this.m_numTravelOptions + "_mc";
         if(ObjectUtil.pathExists(m_window,mainWidgetName))
         {
            this.m_travelClip = new ZwFrame(m_window[mainWidgetName]);
            addWidget(this.m_travelClip,true);
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"largeFrame_mc"))
            {
               displayEAIcon = Boolean(this.m_earlyAccessExpansionWorld) && Boolean(Global.worldManager.getWorldTravelAssetUrl(this.m_earlyAccessExpansionWorld,WorldManager.FASTTRAVELBUYICON));
               callback = null;
               canShowHelpButton = false;
               callbackHelpButton = null;
               if(ObjectUtil.pathExists(m_window[mainWidgetName],"whatisthis_mc"))
               {
                  if(this.m_earlyAccessExpansionWorld != null && WorldsConstants.REGION_WORLDS.indexOf(this.m_earlyAccessExpansionWorld) != -1)
                  {
                     canShowHelpButton = true;
                     callbackHelpButton = this.onEAHelpButtonClick;
                  }
                  if(WorldSeasonsManager.getInstance().isEAUser(this.m_worldTypeToHighlight) && WorldsConstants.REGION_WORLDS.indexOf(this.m_worldTypeToHighlight) != -1)
                  {
                     canShowHelpButton = true;
                     callbackHelpButton = this.onEAHelpButtonClick;
                  }
               }
               if(canShowHelpButton)
               {
                  helpButton = new FarmAnimatedButton(m_window[mainWidgetName].whatisthis_mc,callbackHelpButton);
                  addWidget(helpButton,true);
               }
               if(displayEAIcon && Global.worldManager.hasUnlockedWorld(this.m_earlyAccessExpansionWorld) && WorldSeasonsManager.getInstance().hasSeasons(this.m_earlyAccessExpansionWorld))
               {
                  callback = this.onTravelClickLargeFrame;
               }
               else if(!this.m_isSeason2EarlyAccess || Global.worldManager.currentWorldType == this.m_earlyAccessExpansionWorld)
               {
                  callback = displayEAIcon ? this.onTravelClickBuyEAFrame : this.onTravelClickLargeFrame;
               }
               largeFrme_mc = new FarmAnimatedButton(m_window[mainWidgetName].largeFrame_mc,callback);
               addWidget(largeFrme_mc,true);
               if(ObjectUtil.pathExists(m_window[mainWidgetName].largeFrame_mc,"image_mc") && this.m_availableTravelWorlds != null)
               {
                  if(this.m_isSeason2EarlyAccess)
                  {
                     this.m_travelLargeFrameIconUrl = this.m_earlyAccessExpansionWorld;
                  }
                  else
                  {
                     this.m_travelLargeFrameIconUrl = displayEAIcon ? this.m_earlyAccessExpansionWorld : this.m_worldTypeToHighlight;
                  }
                  if(!this.m_isSeason2EarlyAccess && displayEAIcon)
                  {
                     this.m_availableTravelWorlds.push(this.m_worldTypeToHighlight);
                     ++this.m_travelSmallTotalAvailableSlots;
                     this.m_availableTravelWorldsCopy = this.m_availableTravelWorlds.concat();
                  }
                  iconType = null;
                  if(Global.worldManager.hasUnlockedWorld(this.m_travelLargeFrameIconUrl) && WorldSeasonsManager.getInstance().hasSeasons(this.m_travelLargeFrameIconUrl))
                  {
                     if(WorldSeasonsManager.getInstance().isEAUser(this.m_travelLargeFrameIconUrl) && WorldSeasonsManager.getInstance().getAvailableSeason(this.m_travelLargeFrameIconUrl,ExpansionData.KEY_SEASON_EA) > 0)
                     {
                        if(this.m_earlyAccessExpansionWorld)
                        {
                           iconType = WorldManager.FASTTRAVELBUYICON + String(WorldSeasonsManager.getInstance().getAvailableSeason(this.m_travelLargeFrameIconUrl,ExpansionData.KEY_SEASON_EA));
                        }
                        else
                        {
                           iconType = WorldManager.FASTTRAVELLARGEICON + String(WorldSeasonsManager.getInstance().getAvailableSeason(this.m_travelLargeFrameIconUrl,ExpansionData.KEY_SEASON_EA));
                        }
                     }
                     else if(WorldSeasonsManager.getInstance().getAvailableSeason(this.m_travelLargeFrameIconUrl,ExpansionData.KEY_SEASON_GA) > 0)
                     {
                        iconType = WorldManager.FASTTRAVELLARGEICON + String(WorldSeasonsManager.getInstance().getAvailableSeason(this.m_travelLargeFrameIconUrl,ExpansionData.KEY_SEASON_GA));
                     }
                     else
                     {
                        iconType = WorldManager.FASTTRAVELLARGEICON;
                     }
                  }
                  else if(this.m_isSeason2EarlyAccess)
                  {
                     iconType = Global.worldManager.currentWorldType == this.m_earlyAccessExpansionWorld ? WorldManager.FASTTRAVELBUYICON2 : WorldManager.FASTTRAVELSEASON2ICON;
                  }
                  else
                  {
                     largeIconType = WorldSeasonsManager.getInstance().getCurrentSeason(this.m_worldTypeToHighlight) == WorldSeasonsManager.SEASON_TWO ? WorldManager.FASTTRAVELLARGEICON2 : WorldManager.FASTTRAVELLARGEICON;
                     if(!displayEAIcon && this.m_worldTypeToHighlight == WorldsConstants.WORLD_ID_MIDWEST)
                     {
                        if(WorldSeasonsManager.getInstance().isEAWeek(this.m_worldTypeToHighlight))
                        {
                           largeIconType = WorldManager.FASTTRAVELLARGEICON2;
                        }
                        else if(WorldSeasonsManager.getInstance().isGAFirstWeek(this.m_worldTypeToHighlight))
                        {
                           largeIconType = WorldManager.FASTTRAVELLARGEICON1;
                        }
                     }
                     iconType = displayEAIcon ? WorldManager.FASTTRAVELBUYICON : largeIconType;
                  }
                  assetUrl = Global.worldManager.getWorldTravelAssetUrl(this.m_travelLargeFrameIconUrl,iconType);
                  if(assetUrl != null)
                  {
                     icon = new FarmIcon(m_window[mainWidgetName].largeFrame_mc.image_mc,assetUrl);
                     icon.setIconSize(LARGE_FRAME_ICON_WIDTH,LARGE_FRAME_ICON_HEIGHT);
                     addWidget(icon,true);
                  }
               }
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"btnPanel_mc"))
            {
               btnPanelVisible = this.m_isSeason2EarlyAccess && Global.worldManager.currentWorldType != this.m_earlyAccessExpansionWorld ? true : false;
               addWidget(new ZwFrame(m_window[mainWidgetName].btnPanel_mc),btnPanelVisible);
               if(ObjectUtil.pathExists(m_window[mainWidgetName].btnPanel_mc,"travel_bt"))
               {
                  addWidget(new FarmAnimatedTextButton(m_window[mainWidgetName].btnPanel_mc.travel_bt,"Travel",this.onTravelClickLargeFrame),true);
               }
               if(ObjectUtil.pathExists(m_window[mainWidgetName].btnPanel_mc,"buy_bt"))
               {
                  addWidget(new FarmAnimatedTextButton(m_window[mainWidgetName].btnPanel_mc.buy_bt,"Buy Early Access",this.onTravelClickBuyEAFrame),true);
               }
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"smallFrame_mc"))
            {
               this.m_travelSmallFrame = new TravelDialogSmallFrame(m_window[mainWidgetName].smallFrame_mc,this.onTravelCallBack);
               addWidget(this.m_travelSmallFrame);
               if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_WINDOW_SORTING_PREFERENCE) == 1)
               {
                  this.sortWorld(this.m_selected);
               }
               else
               {
                  if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_DIALOG_SORT) == Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
                  {
                     this.sortTravelDialogSmallIcons();
                  }
                  else
                  {
                     this.m_availableTravelWorlds.sort(this.sortTravelWorldBasedOnListPriorityDesc);
                  }
                  this.m_travelSmallFrame.travelSlots = this.m_availableTravelWorlds;
               }
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"pause_bt"))
            {
               travelFreezeWidget = addWidget(new FarmButton(m_window[mainWidgetName].pause_bt,this.toggleFreezeWorld),true);
               if(travelFreezeWidget != null && ObjectUtil.pathExists(m_window[mainWidgetName].pause_bt,"checkBack_mc"))
               {
                  this.m_travelShouldFreezeWorld = addWidget(new ZwBaseWidget(m_window[mainWidgetName].pause_bt.checkBack_mc),true);
               }
               if(travelFreezeWidget != null && ObjectUtil.pathExists(m_window[mainWidgetName].pause_bt,"check_mc"))
               {
                  this.m_travelShouldFreezeWorldCheck = addWidget(new ZwBaseWidget(m_window[mainWidgetName].pause_bt.check_mc),this.m_shouldFreezeFarm);
               }
               if(travelFreezeWidget != null && ObjectUtil.pathExists(m_window[mainWidgetName].pause_bt,"generic_tf"))
               {
                  pauseText = ZLocUtils.t("Dialogs","TravelFreezeSelect_ChooseOptions",{"world":Global.worldManager.getWorldFriendlyName()});
                  addWidget(new FarmTextField(m_window[mainWidgetName].pause_bt.generic_tf,pauseText),true);
               }
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"sortRelease_bt"))
            {
               travelSortWidgetRelease = addWidget(new FarmButton(m_window[mainWidgetName].sortRelease_bt,this.toggleButtonAndSortWorlds),true);
               if(travelSortWidgetRelease != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortRelease_bt,"checkBack1_mc"))
               {
                  this.m_travelShouldSortWorldRelease = addWidget(new ZwBaseWidget(m_window[mainWidgetName].sortRelease_bt.checkBack1_mc),true);
               }
               if(travelSortWidgetRelease != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortRelease_bt,"check1_mc"))
               {
                  this.m_travelShouldSortWorldReleaseCheck = addWidget(new ZwBaseWidget(m_window[mainWidgetName].sortRelease_bt.check1_mc),!this.m_selected);
               }
               if(travelSortWidgetRelease != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortRelease_bt,"generic1_tf"))
               {
                  sortReleaseText = ZLocUtils.t("Dialogs","TravelSortSelect_Release");
                  addWidget(new FarmTextField(m_window[mainWidgetName].sortRelease_bt.generic1_tf,sortReleaseText),true);
               }
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"sortLastVisit_bt"))
            {
               travelSortWidgetLastVisit = addWidget(new FarmButton(m_window[mainWidgetName].sortLastVisit_bt,this.toggleButtonAndSortWorlds),true);
               if(travelSortWidgetLastVisit != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortLastVisit_bt,"checkBack2_mc"))
               {
                  this.m_travelShouldSortWorldLastVisit = addWidget(new ZwBaseWidget(m_window[mainWidgetName].sortLastVisit_bt.checkBack2_mc),true);
               }
               if(travelSortWidgetLastVisit != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortLastVisit_bt,"check2_mc"))
               {
                  this.m_travelShouldSortWorldLastVisitCheck = addWidget(new ZwBaseWidget(m_window[mainWidgetName].sortLastVisit_bt.check2_mc),this.m_selected);
               }
               if(travelSortWidgetLastVisit != null && ObjectUtil.pathExists(m_window[mainWidgetName].sortLastVisit_bt,"generic2_tf"))
               {
                  sortLastVisitText = ZLocUtils.t("Dialogs","TravelSortSelect_LastVisit");
                  addWidget(new FarmTextField(m_window[mainWidgetName].sortLastVisit_bt.generic2_tf,sortLastVisitText),true);
               }
            }
            numSmallSlots = this.m_availableTravelWorlds.length;
            showPaging = numSmallSlots > SHOW_THREE_WORLD_TO_TRAVEL ? true : false;
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"arrowLeft_bt"))
            {
               this.m_arrowLeft = addWidget(new FarmButton(m_window[mainWidgetName].arrowLeft_bt,this.refreshSlotImagesLeft),showPaging) as FarmButton;
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"arrowRight_bt"))
            {
               this.m_arrowRight = addWidget(new FarmButton(m_window[mainWidgetName].arrowRight_bt,this.refreshSlotImagesRight),showPaging) as FarmButton;
            }
            if(ObjectUtil.pathExists(m_window[mainWidgetName],"generic_tf"))
            {
               this.m_travelFreezeDesciption = new FarmTextField(m_window[mainWidgetName].generic_tf);
               this.m_travelClip.addWidget(this.m_travelFreezeDesciption,true);
            }
            if(this.m_earlyAccessExpansionWorld != null)
            {
               if(ObjectUtil.pathExists(m_window[mainWidgetName],"time_mc"))
               {
                  access = this.getEarlyExpansionAccessData(this.m_earlyAccessExpansionWorld);
                  if(access)
                  {
                     daysLeft = access.daysLeft;
                     if(daysLeft >= 0)
                     {
                        m_window[mainWidgetName].time_mc.visible = true;
                        m_window[mainWidgetName].time_mc.time_tf.visible = true;
                        if(daysLeft > 1)
                        {
                           m_window[mainWidgetName].time_mc.time_tf.text = daysLeft + " days left";
                        }
                        else if(daysLeft == 1)
                        {
                           m_window[mainWidgetName].time_mc.time_tf.text = daysLeft + " day left";
                        }
                        else
                        {
                           m_window[mainWidgetName].time_mc.time_tf.text = "few hours left";
                        }
                     }
                  }
               }
            }
            this.setupTravelText();
            this.setPagingButtonsBasedOnPosition();
         }
      }
      
      private function toggleFreezeWorld(event:Event) : void
      {
         if(this.m_travelShouldFreezeWorldCheck != null)
         {
            if(this.m_shouldFreezeFarm)
            {
               this.m_shouldFreezeFarm = false;
            }
            else
            {
               this.m_shouldFreezeFarm = true;
            }
            this.setupTravelText();
            this.m_travelShouldFreezeWorldCheck.visible = this.m_shouldFreezeFarm;
         }
      }
      
      private function toggleButtonAndSortWorlds(event:Event) : void
      {
         if(this.m_travelShouldSortWorldReleaseCheck != null && this.m_travelShouldSortWorldLastVisitCheck != null)
         {
            if(this.m_selected)
            {
               this.m_selected = false;
               this.m_travelShouldSortWorldReleaseCheck.visible = true;
               this.m_travelShouldSortWorldLastVisitCheck.visible = false;
            }
            else
            {
               this.m_selected = true;
               this.m_travelShouldSortWorldReleaseCheck.visible = false;
               this.m_travelShouldSortWorldLastVisitCheck.visible = true;
            }
            this.sortWorld(this.m_selected);
         }
      }
      
      private function sortWorld(m_selected:Boolean = false) : void
      {
         this.m_availableTravelWorlds = this.m_availableTravelWorldsCopy.concat();
         if(m_selected)
         {
            this.sortTravelDialogSmallIcons();
         }
         else
         {
            this.m_availableTravelWorlds.sort(this.sortTravelWorldBasedOnListPriorityDesc);
         }
         this.m_travelSmallFrame.travelSlots = this.m_availableTravelWorlds;
         this.refreshSlotImages();
      }
      
      private function setPagingButtonsBasedOnPosition() : void
      {
         if(this.m_arrowLeft != null && this.m_arrowRight != null)
         {
            this.m_arrowLeft.visible = this.m_travelSmallIconStartIndex > 0 ? true : false;
            this.m_arrowRight.visible = this.m_travelSmallIconStartIndex + SHOW_TWO_WORLD_TO_TRAVEL < this.m_travelSmallTotalAvailableSlots ? true : false;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         var currentFarm:String = null;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TRAVEL_WINDOW_SORTING_PREFERENCE) == 1)
         {
            currentFarm = Global.worldManager.currentWorldType;
            if(this.m_selected)
            {
               FarmStatsManager.count("travel_interstitial","sort","recently_visited","","",currentFarm);
               Global.player.setSeenFlag(TRAVEL_WINDOW_SORTING_KEY,true);
            }
            else
            {
               FarmStatsManager.count("travel_interstitial","sort","latest_farm","","",currentFarm);
               Global.player.resetSeenFlagTravelWindowSorting();
            }
         }
         super.close();
      }
      
      private function refreshSlotImages() : void
      {
         var travelWorldsToDisplay:Array = null;
         var i:int = 0;
         if(this.m_travelSmallFrame != null)
         {
            travelWorldsToDisplay = new Array();
            for(i = 0; i <= this.m_travelSmallTotalAvailableSlots; i++)
            {
               travelWorldsToDisplay.push(this.m_availableTravelWorlds[i]);
            }
            this.m_travelSmallFrame.travelSlots = travelWorldsToDisplay;
            this.m_travelSmallIconStartIndex = 0;
         }
         this.setPagingButtonsBasedOnPosition();
      }
      
      private function refreshSlotImagesRight(event:Event) : void
      {
         var travelWorldsToDisplay:Array = null;
         var i:int = 0;
         if(this.m_arrowLeft != null)
         {
            if(this.m_travelSmallIconStartIndex + SHOW_TWO_WORLD_TO_TRAVEL < this.m_travelSmallTotalAvailableSlots)
            {
               this.m_travelSmallIconStartIndex += 3;
               if(this.m_travelSmallFrame != null)
               {
                  travelWorldsToDisplay = new Array();
                  for(i = this.m_travelSmallIconStartIndex; i <= this.m_travelSmallTotalAvailableSlots; i++)
                  {
                     travelWorldsToDisplay.push(this.m_availableTravelWorlds[i]);
                  }
                  this.m_travelSmallFrame.travelSlots = travelWorldsToDisplay;
               }
            }
            this.setPagingButtonsBasedOnPosition();
         }
      }
      
      private function refreshSlotImagesLeft(event:Event) : void
      {
         var travelWorldsToDisplay:Array = null;
         var i:int = 0;
         if(this.m_arrowRight != null)
         {
            if(this.m_travelSmallIconStartIndex > 0)
            {
               this.m_travelSmallIconStartIndex -= 3;
               if(this.m_travelSmallFrame != null)
               {
                  travelWorldsToDisplay = new Array();
                  for(i = this.m_travelSmallIconStartIndex; i <= this.m_travelSmallTotalAvailableSlots; i++)
                  {
                     travelWorldsToDisplay.push(this.m_availableTravelWorlds[i]);
                  }
                  this.m_travelSmallFrame.travelSlots = travelWorldsToDisplay;
               }
            }
            this.setPagingButtonsBasedOnPosition();
         }
      }
      
      private function onTravelClickLargeFrame(event:Event) : void
      {
         if(this.m_worldTypeToHighlight != null)
         {
            this.onTravelCallBack(this.m_worldTypeToHighlight);
         }
      }
      
      private function onTravelClickBuyEAFrame(event:Event) : void
      {
         var access:ExpansionAccess = null;
         if(this.m_earlyAccessExpansionWorld != null)
         {
            access = this.getEarlyExpansionAccessData(this.m_earlyAccessExpansionWorld);
            if(access)
            {
               UI.displayMessage(ZLocUtils.t("Dialogs","EA_MOTD_Confirmation_Body",{"price":access.cashCost}),GenericPopup.TYPE_ACCEPTCANCEL,this.onConfirmationFinished,ExpansionEarlyAccessMotdHandler.EA_CONFIRMATION_UNIQUE_NAME,true,true);
            }
         }
      }
      
      protected function onConfirmationFinished(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.ACCEPT)
         {
            this.onBuyEarlyAccessConfirmation();
         }
      }
      
      private function onBuyEarlyAccessConfirmation() : void
      {
         var worldName:String = null;
         var access:ExpansionAccess = this.getEarlyExpansionAccessData(this.m_earlyAccessExpansionWorld);
         if(access)
         {
            if(Global.player.canBuyCash(access.cashCost,true,"expansion_early_access_" + this.m_earlyAccessExpansionWorld))
            {
               Global.player.cash -= access.cashCost;
               TransactionManager.addTransaction(new TExpansionWorldAccess(this.m_earlyAccessExpansionWorld,access.type,true,null,this.onEarlyAccessBuyComplete),true);
               worldName = this.m_earlyAccessExpansionWorld;
               if(this.m_isSeason2EarlyAccess)
               {
                  worldName = "kingdom";
               }
               FarmStatsManager.count("travel_ui","unlock_world",worldName,"click","ok");
               FreezeManager.freezeAll(false);
            }
         }
      }
      
      private function onEarlyAccessBuyComplete() : void
      {
         FreezeManager.thaw();
         this.close();
      }
      
      private function getEarlyExpansionAccessData(worldId:String) : ExpansionAccess
      {
         var access:ExpansionAccess = null;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
         if(expansionData)
         {
            access = expansionData.getAccessOfType(ExpansionAccess.TYPE_EARLY);
         }
         return access;
      }
      
      private function onTravelCallBack(worldType:String = null) : void
      {
         var expansionData:ExpansionData = null;
         worldType = worldType == null ? this.m_worldTypeToHighlight : worldType;
         var options:Object = Global.player.options;
         if(options.shouldFreezeFarm != this.m_shouldFreezeFarm)
         {
            options.shouldFreezeFarm = this.m_shouldFreezeFarm;
            TransactionManager.addTransaction(new TSaveOptions(options));
         }
         this.onClose(null);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SASHA_THE_GROCER) <= 1)
         {
            Global.worldManager.swapFarm(worldType,this.m_shouldFreezeFarm);
         }
         else
         {
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(Global.worldManager.hasUnlockedWorld(worldType))
            {
               Global.worldManager.swapFarm(worldType,this.m_shouldFreezeFarm);
            }
            else if(Boolean(expansionData) && expansionData.staticWorld == true)
            {
               Global.worldManager.visitStaticFarm(worldType);
            }
         }
      }
      
      private function setUpInitialFrameData() : void
      {
         var i:* = 0;
         var allWorldTypes:Array = null;
         var worldId:String = null;
         var expansionData:ExpansionData = null;
         var worldType:String = null;
         this.m_selected = Global.player.getSeenFlag(TRAVEL_WINDOW_SORTING_KEY);
         if(Global.player.options.hasOwnProperty("shouldFreezeFarm"))
         {
            this.m_shouldFreezeFarm = Global.player.options.shouldFreezeFarm > 0;
         }
         else
         {
            this.m_shouldFreezeFarm = false;
         }
         var allUnlockedWorlds:Array = Global.worldManager.unlockedWorldTypes;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_SASHA_THE_GROCER) <= 1)
         {
            this.m_availableTravelWorlds = allUnlockedWorlds.slice(0,allUnlockedWorlds.length);
         }
         else
         {
            this.m_availableTravelWorlds = new Array();
            allWorldTypes = WorldsConstants.ALL_WORLDS;
            for each(worldId in allWorldTypes)
            {
               expansionData = Global.farmGameSettingsManager.getExpansionData(worldId);
               if(Global.worldManager.hasUnlockedWorld(worldId) && this.isEarlyAccessExpansionAvailable(worldId) && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_AVALON && expansionData.seasonNumber == WorldSeasonsManager.SEASON_TWO)
               {
                  this.m_isSeason2EarlyAccess = true;
                  this.m_earlyAccessExpansionWorld = worldId;
                  this.m_availableTravelWorlds.push(worldId);
               }
               else if(Global.worldManager.hasUnlockedWorld(worldId) || Boolean(expansionData && expansionData.passesPrereqs()) && Boolean(expansionData.staticWorld == true))
               {
                  this.m_availableTravelWorlds.push(worldId);
               }
               else if(this.isEarlyAccessExpansionAvailable(worldId))
               {
                  if(worldId != WorldsConstants.WORLD_ID_MEADOWS)
                  {
                     this.m_earlyAccessExpansionWorld = worldId;
                  }
               }
            }
         }
         for(i = 0; i < this.m_availableTravelWorlds.length; i++)
         {
            worldType = this.m_availableTravelWorlds[i];
            expansionData = Global.farmGameSettingsManager.getExpansionData(worldType);
            if(Boolean(expansionData) && !expansionData.showInTravelDialog)
            {
               this.m_availableTravelWorlds.splice(i,1);
               i--;
            }
         }
         this.m_availableTravelWorlds.sort(this.sortTravelWorldBasedOnListPriorityAsc);
         this.m_latestUnlockedExpansionType = this.m_availableTravelWorlds[this.m_availableTravelWorlds.length - 1];
         if(this.m_isSeason2EarlyAccess == false || Global.worldManager.currentWorldType != this.m_earlyAccessExpansionWorld)
         {
            ArrayUtil.removeValueFromArray(this.m_availableTravelWorlds,Global.worldManager.currentWorldType);
         }
         var slotToView:Number = this.m_availableTravelWorlds.length;
         this.m_numTravelOptions = slotToView > SHOW_FOUR_WORLD_TO_TRAVEL ? SHOW_FOUR_WORLD_TO_TRAVEL : slotToView;
         this.m_worldTypeToHighlight = this.getLargeTravelAssetToHighLight();
         ArrayUtil.removeValueFromArray(this.m_availableTravelWorlds,this.m_worldTypeToHighlight);
         this.m_travelSmallIconStartIndex = 0;
         this.m_travelSmallTotalAvailableSlots = this.m_availableTravelWorlds.length - 1;
         this.m_availableTravelWorldsCopy = this.m_availableTravelWorlds.concat();
      }
      
      private function sortTravelDialogSmallIcons() : void
      {
         var lastVisitSortArray:Array = new Array();
         var listPrioritySortArray:Array = new Array();
         var availableWorldsCount:int = int(this.m_availableTravelWorlds.length);
         for(var i:int = 0; i < availableWorldsCount; i++)
         {
            if(Global.worldManager.getLastWorldVisitTime(this.m_availableTravelWorlds[i]) > 0)
            {
               lastVisitSortArray.push(this.m_availableTravelWorlds[i]);
            }
            else
            {
               listPrioritySortArray.push(this.m_availableTravelWorlds[i]);
            }
         }
         lastVisitSortArray.sort(this.sortTravelWorldBasedOnLastVisitTimeDesc);
         listPrioritySortArray.sort(this.sortTravelWorldBasedOnListPriorityDesc);
         this.m_availableTravelWorlds = lastVisitSortArray.concat(listPrioritySortArray);
      }
      
      private function isEarlyAccessExpansionAvailable(worldId:String) : Boolean
      {
         var result:Boolean = false;
         var access:ExpansionAccess = this.getEarlyExpansionAccessData(worldId);
         if(access)
         {
            if(access.checkPrereqs())
            {
               result = true;
            }
         }
         return result;
      }
      
      private function setupTravelText() : void
      {
         var bodyText:String = " ";
         if(this.m_shouldFreezeFarm)
         {
            bodyText += ZLocUtils.t("Dialogs","TravelFreezeSelect_Body_freeze");
         }
         else
         {
            bodyText += ZLocUtils.t("Dialogs","TravelFreezeSelect_Body_nofreeze");
         }
         this.m_travelFreezeDesciption.text = bodyText;
      }
      
      public function sortTravelWorldBasedOnListPriorityAsc(worldConfig1:String, worldConfig2:String) : int
      {
         return this.getTravelListPriority(worldConfig1) - this.getTravelListPriority(worldConfig2);
      }
      
      public function sortTravelWorldBasedOnListPriorityDesc(worldConfig1:String, worldConfig2:String) : int
      {
         return this.getTravelListPriority(worldConfig2) - this.getTravelListPriority(worldConfig1);
      }
      
      private function sortTravelWorldBasedOnLastVisitTimeDesc(worldConfig1:String, worldConfig2:String) : int
      {
         return Global.worldManager.getLastWorldVisitTime(worldConfig2) - Global.worldManager.getLastWorldVisitTime(worldConfig1);
      }
      
      private function getTravelListPriority(worldType:String) : Number
      {
         var hudSkinConfig:HUDSkinConfig = null;
         var listPriority:Number = -1;
         var worldConfig:Object = Global.worldSettingsManager.getConfigByWorld(worldType);
         if(Boolean(worldConfig) && Boolean(worldConfig.hudSkinConfig))
         {
            hudSkinConfig = worldConfig.hudSkinConfig as HUDSkinConfig;
            if(hudSkinConfig)
            {
               listPriority = hudSkinConfig.travelDropDownListPriority;
            }
         }
         return listPriority;
      }
      
      private function getLargeTravelAssetToHighLight() : String
      {
         var currentWorldType:String = Global.worldManager.currentWorldType;
         var travelAssetToHighLight:String = currentWorldType == this.m_latestUnlockedExpansionType && !this.m_isSeason2EarlyAccess ? WorldsConstants.WORLD_ID_HOME : this.m_latestUnlockedExpansionType;
         var expansionData:ExpansionData = Global.farmGameSettingsManager.getExpansionData(this.m_latestUnlockedExpansionType);
         return travelAssetToHighLight;
      }
      
      public function setUpTravelOptions() : Number
      {
         var unlockedWorlds:Array = Global.worldManager.getAvailableTravelWorlds();
         return unlockedWorlds.length;
      }
      
      private function onEAHelpButtonClick(eve:Event) : void
      {
         UI.displayPopup(new TravelDialogTutorialWindow(TUTORIAL_EA_URL),false);
      }
      
      private function onHelpButtonClick(eve:Event) : void
      {
         UI.displayPopup(new TravelDialogTutorialWindow(TUTORIAL_EA_URL),false);
      }
   }
}


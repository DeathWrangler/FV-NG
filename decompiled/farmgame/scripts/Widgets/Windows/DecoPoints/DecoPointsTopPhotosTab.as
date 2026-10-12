package Widgets.Windows.DecoPoints
{
   import Classes.Constants.Experiments;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Events.MarketEvent;
   import Managers.DecoPointsManager;
   import Managers.FarmStatsManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.TextFields.FarmTextField;
   import Widgets.View.Tooltips.ToolTipManager;
   import Widgets.Windows.MOTD.TopPhotosMOTDWindow;
   import Widgets.Windows.Market.MarketWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class DecoPointsTopPhotosTab extends ZwFrame
   {
      
      public static const EVENT_MINI_MARKET_BUTTON_CLICKED:String = "event_mini_market_button_clicked";
      
      private static const IMAGE_SIZE:int = 307;
      
      private var m_nextButton:ZwButton;
      
      private var m_previousButton:ZwButton;
      
      private var m_entryIndex:uint = 0;
      
      private var m_topEntries:Array;
      
      private var m_entryImage:FarmIcon;
      
      private var m_ribbon:MovieClip;
      
      private var m_playerInfoFrame:ZwFrame;
      
      private var m_playerName:FarmTextField;
      
      private var m_playerProfileImage:FarmIcon;
      
      private var m_miniMarketButton:ZwButton;
      
      private var m_noPhotosText:FarmTextField;
      
      private var m_numVotesText:FarmTextField;
      
      public function DecoPointsTopPhotosTab(element:MovieClip, decoPointsManager:DecoPointsManager, isMOTD:Boolean = false)
      {
         var miniMarketButtonText:String = null;
         super(element);
         if(isMOTD)
         {
            addWidget(new FarmTextField(element.title_tf,ZLocUtils.t("Dialogs","topPhotosMOTD_title")));
            miniMarketButtonText = ZLocUtils.t("Dialogs","topPhotosMOTD_MiniMarketButtonText");
            addWidget(new FarmTextField(element.generic_0_tf,ZLocUtils.t("Dialogs","topPhotosMOTD_sub_title")));
         }
         else
         {
            miniMarketButtonText = ZLocUtils.t("Dialogs","DPTopPhotosTab_MiniMarketButtonText");
            addWidget(new FarmTextField(element.generic_0_tf,ZLocUtils.t("Dialogs","topPhotosChallengeNameHeader")));
            addWidget(new FarmTextField(element.challenge_tf,decoPointsManager.getWeeklyPhotoContestTheme()));
            addWidget(new FarmTextField(element.generic_1_tf,ZLocUtils.t("Dialogs","topPhotosViewTopPhotosInstruction")));
            this.m_numVotesText = addWidget(new FarmTextField(element.votes_tf)) as FarmTextField;
            this.m_noPhotosText = addWidget(new FarmTextField(element.generic_2_tf,ZLocUtils.t("Dialogs","DPVoteTab_EmptyTopPhotos"))) as FarmTextField;
            this.m_noPhotosText.visible = false;
         }
         this.m_nextButton = addWidget(new ZwButton(element.arrowRight_bt,this.onNextClick)) as ZwButton;
         this.m_previousButton = addWidget(new ZwButton(element.arrowLeft_bt,this.onPreviousClick)) as ZwButton;
         this.m_entryImage = addWidget(new FarmIcon(element.icon_mc)) as FarmIcon;
         this.m_ribbon = element.ribbon_mc;
         this.m_playerInfoFrame = new ZwFrame(element.playerInfo_mc);
         this.m_playerName = new FarmTextField(element.playerInfo_mc.name_tf);
         this.m_playerProfileImage = new FarmIcon(element.playerInfo_mc.icon_mc);
         this.m_playerInfoFrame.addWidget(this.m_playerName);
         this.m_playerInfoFrame.addWidget(this.m_playerProfileImage);
         ToolTipManager.getInstance().addToolTip(m_element.market_bt,ZLocUtils.t("Dialogs","DPTopPhotosTab_MiniMarketButtonToolTip"));
         this.m_miniMarketButton = addWidget(new FarmAnimatedTextButton(m_element.market_bt,miniMarketButtonText,this.onOpenMiniMarket)) as FarmAnimatedTextButton;
         addWidget(this.m_playerInfoFrame);
         this.disableUI();
      }
      
      public function populate(topPhotos:Array) : void
      {
         this.m_topEntries = topPhotos;
         this.m_entryIndex = 0;
         if(Boolean(this.m_topEntries) && this.m_topEntries.length > 0)
         {
            this.enableUI();
            this.renderCurrentEntry();
         }
         else
         {
            this.m_noPhotosText.visible = true;
         }
      }
      
      private function disableUI() : void
      {
         this.m_ribbon.visible = false;
         this.m_entryImage.visible = false;
         this.m_playerInfoFrame.visible = false;
         this.m_miniMarketButton.visible = false;
         this.updateArrows();
      }
      
      private function enableUI() : void
      {
         this.m_ribbon.visible = true;
         this.m_entryImage.visible = true;
         this.updateMiniMarketButton();
         this.updateArrows();
      }
      
      private function updateArrows() : void
      {
         this.m_nextButton.visible = Boolean(this.m_topEntries) && this.m_entryIndex < this.m_topEntries.length - 1;
         this.m_previousButton.visible = Boolean(this.m_topEntries) && this.m_entryIndex > 0;
      }
      
      private function renderCurrentEntry() : void
      {
         var entryData:Object = this.m_topEntries[this.m_entryIndex];
         this.m_entryImage.loadIcon(DecoPointsManager.getFullImageUrl(entryData.url));
         this.m_entryImage.setIconSize(IMAGE_SIZE,IMAGE_SIZE);
         if(!(m_parent is TopPhotosMOTDWindow))
         {
            this.m_numVotesText.text = entryData.votes;
            this.m_numVotesText.visible = true;
            this.m_noPhotosText.visible = false;
         }
         this.m_ribbon.gotoAndStop(this.m_entryIndex + 1);
         this.m_ribbon.visible = true;
         var allowShowProfileImage:Boolean = entryData.allowShowProfileImage ? Boolean(entryData.allowShowProfileImage) : true;
         if(Boolean(allowShowProfileImage) && Boolean(entryData.name) && Boolean(entryData.profile_pic))
         {
            this.m_playerInfoFrame.visible = true;
            this.m_playerName.text = entryData.name;
            this.m_playerProfileImage.loadIcon(entryData.profile_pic);
         }
         else
         {
            this.m_playerInfoFrame.visible = false;
         }
         this.updateArrows();
         this.updateMiniMarketButton();
      }
      
      private function onNextClick(event:Event) : void
      {
         ++this.m_entryIndex;
         this.renderCurrentEntry();
      }
      
      private function onPreviousClick(event:Event) : void
      {
         --this.m_entryIndex;
         this.renderCurrentEntry();
      }
      
      private function onOpenMiniMarket(event:Event) : void
      {
         var itemCodes:Array = null;
         var itemNames:Array = null;
         var itemCodesLength:int = 0;
         var i:int = 0;
         var miniMarketWindow:MarketWindow = null;
         var entryData:Object = this.m_topEntries[this.m_entryIndex];
         if(entryData.hasOwnProperty("itemCodes") && entryData["itemCodes"] != null)
         {
            itemCodes = entryData["itemCodes"];
            if(itemCodes.length > 0)
            {
               itemNames = new Array();
               itemCodesLength = int(itemCodes.length);
               FarmStatsManager.count("deco_points","","decorateNow","topPhotos","","",1);
               for(i = 0; i < itemCodesLength; i++)
               {
                  itemNames.push(Global.farmGameSettingsManager.getFarmItemNameByCode(itemCodes[i]));
               }
               miniMarketWindow = UI.displayMiniMarketDialog(itemNames,UI.MARKET_CONTEXT_UNKNOWN,"",null,false) as MarketWindow;
               miniMarketWindow.addEventListener(MarketEvent.MARKET_BUY,this.closeParentWindowOnMiniMarketPurchase);
               dispatchEvent(new Event(EVENT_MINI_MARKET_BUTTON_CLICKED));
            }
         }
      }
      
      private function updateMiniMarketButton() : void
      {
         var entryData:Object = null;
         var itemCodes:Array = null;
         this.m_miniMarketButton.visible = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_DP_ITEM_TAGGING) >= 1)
         {
            entryData = this.m_topEntries[this.m_entryIndex];
            if(entryData.hasOwnProperty("itemCodes") && entryData["itemCodes"] != null)
            {
               itemCodes = entryData["itemCodes"];
               this.m_miniMarketButton.visible = itemCodes.length > 0;
            }
         }
      }
      
      private function closeParentWindowOnMiniMarketPurchase(event:Event) : void
      {
         dispatchEvent(new MarketEvent(MarketEvent.MARKET_BUY));
      }
   }
}


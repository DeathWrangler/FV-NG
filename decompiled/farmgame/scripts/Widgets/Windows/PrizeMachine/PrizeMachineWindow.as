package Widgets.Windows.PrizeMachine
{
   import Classes.Constants.Experiments;
   import Classes.Constants.QuestConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.UserRewardUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.ImpulseBuy;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Managers.TransactionManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureOptionsManager;
   import Managers.ToasterManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Constants.Market.Currency;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.PrizeMachine.PrizeMachineChipFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.FreeGiftSelectionWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PrizeMachineWindow extends FarmWindow
   {
      
      public static const STAT_COUNTER:String = "game_prize_machine";
      
      private static const ASSET_PATH:String = "assets/dialogs/FV_prizeMachine.swf";
      
      public static const PRIZE_MACHINE_FREE_SPIN:String = "SECURE_prizeMachine_FreeSpin";
      
      public static const COLLECTION_CHIP_ASSET:String = "assets/collect/collect_prizemachinetoken_icon.png";
      
      public static const FREE_SPIN_ASSET:String = "assets/consumables/consume_prizemachinetoken_icon.png";
      
      private static const SOUND_PRIZE_DROP:String = "prize_machine_prize_drop";
      
      private static const SOUND_PRIZE_AWARDED:String = "prize_machine_prize_awarded";
      
      private static const SOUND_MACHINE_CRANK:String = "prize_machine_crank";
      
      private static const SOUND_COLLECTION_PRIZE:String = "prize_machine_collection_prize";
      
      private static const FARM_CASH_ICON:String = "assets/consumables/fv_cash.png";
      
      private var m_playButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedCashButton;
      
      private var m_farmCashIcon:ZwBaseWidget;
      
      private var m_farmCashCost:ZwTextField;
      
      private var m_freeSpin:ZwBaseWidget;
      
      private var m_prizeFrame:ZwBaseWidget;
      
      private var m_prizeBubble:ZwFrame;
      
      private var m_rewardFrame:ZwFrame;
      
      private var m_collectionChipsFrame:PrizeMachineChipFrame;
      
      private var m_rewardName:ZwTextField;
      
      private var m_rewardQuantity:ZwTextField;
      
      private var m_rewardIcon:FarmIcon;
      
      private var m_spinnerAnimation:ZwBaseWidget;
      
      private var m_loading:ZwBaseWidget;
      
      private var m_clearAnimation:Boolean = false;
      
      private var m_rarePrizeAwarded:Boolean = false;
      
      private var m_showToaster:Boolean = true;
      
      public function PrizeMachineWindow()
      {
         super(ASSET_PATH);
         SoundManager.addSound(SOUND_PRIZE_DROP,Global.getAssetURL("assets/sounds/prizemachine/PrizeMachine_PrizeDrop.mp3"),false);
         SoundManager.addSound(SOUND_PRIZE_AWARDED,Global.getAssetURL("assets/sounds/prizemachine/PrizeMachine_PrizeAwarded.mp3"),false);
         SoundManager.addSound(SOUND_MACHINE_CRANK,Global.getAssetURL("assets/sounds/prizemachine/PrizeMachine_Crank.mp3"),false);
         SoundManager.addSound(SOUND_COLLECTION_PRIZE,Global.getAssetURL("assets/sounds/prizemachine/PrizeMachine_CollectionPrizeAwarded.mp3"),false);
      }
      
      public static function getTimeLeft() : Number
      {
         var runtimeValue:String = null;
         var runtimeConfigs:Array = null;
         var i:int = 0;
         var runtimeTokens:Array = null;
         var startTime:uint = 0;
         var expireTime:uint = 0;
         var serverTime:uint = 0;
         var result:Number = -1;
         if(Global.flashHotParams["PRIZE_MACHINE_GRAND_PRIZE"] != null)
         {
            runtimeValue = Global.flashHotParams["PRIZE_MACHINE_GRAND_PRIZE"];
            runtimeConfigs = runtimeValue.split(/,/);
            for(i = 0; i < runtimeConfigs.length; i++)
            {
               runtimeTokens = runtimeConfigs[i].split(/:/);
               if(runtimeTokens.length == 3)
               {
                  startTime = FarmGameUtil.synchronizedDateToNumber(runtimeTokens[1]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  expireTime = FarmGameUtil.synchronizedDateToNumber(runtimeTokens[2]) / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  serverTime = GlobalEngine.serverTime / FarmGameUtil.NUM_MSECS_IN_SECOND;
                  if(expireTime > serverTime && serverTime > startTime)
                  {
                     if(expireTime > serverTime)
                     {
                        result = expireTime - serverTime;
                     }
                  }
               }
            }
         }
         else if(Config.DEBUG_MODE && result == -1)
         {
            UI.displayMessage("Prize Machine - The current runtime configuration is not valid");
            throw new Error("Prize Machine - Missing runtime configuration");
         }
         return result;
      }
      
      public static function getSpinCost() : int
      {
         var result:int = 2;
         var expVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE);
         if(expVariant == 4 || expVariant == 6 || expVariant == 8 || expVariant == 10)
         {
            result = 3;
         }
         return result;
      }
      
      public static function isTimedVariant() : Boolean
      {
         var result:Boolean = true;
         var expVariant:int = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_PRIZE_MACHINE);
         if(expVariant == 5 || expVariant == 6 || expVariant == 9 || expVariant == 10)
         {
            result = false;
         }
         return result;
      }
      
      override protected function onLoadComplete(event:Event) : void
      {
         var freeSpinBurst:ZwBaseWidget = null;
         super.onLoadComplete(event);
         FarmStatsManager.count(STAT_COUNTER,"surface_motd","view");
         addWidget(new ZwTextField(m_window.header1_txt,ZLocUtils.t("Dialogs","PrizeMachine_Title")));
         addWidget(new ZwTextField(m_window.header2_txt,ZLocUtils.t("Dialogs","PrizeMachine_Subtitle")));
         var collectMessage:String = null;
         if(PrizeMachineWindow.isTimedVariant())
         {
            collectMessage = ZLocUtils.t("Dialogs","PrizeMachine_ChipText_timed");
         }
         else
         {
            collectMessage = ZLocUtils.t("Dialogs","PrizeMachine_ChipText_untimed");
         }
         addWidget(new ZwTextField(m_window.subHead_txt,collectMessage));
         addWidget(this.m_buyButton = new FarmAnimatedCashButton(m_window.buy_bt,ZLocUtils.t("Dialogs","Play"),PrizeMachineWindow.getSpinCost().toString(),this.onBuyPrize));
         addWidget(this.m_playButton = new FarmAnimatedTextButton(m_window.playButton_mc,ZLocUtils.t("Dialogs","Play"),this.onBuyPrize));
         addWidget(this.m_freeSpin = new ZwBaseWidget(m_window.freeplay_mc));
         addWidget(this.m_spinnerAnimation = new ZwBaseWidget(m_window.animation_mc));
         (this.m_spinnerAnimation.element as MovieClip).stop();
         addWidget(this.m_loading = new ZwBaseWidget(m_window.loader_mc),false);
         addWidget(new FarmAnimatedTextButton(m_window.moreInfo_bt,"",this.onMoreInfo));
         addWidget(this.m_prizeFrame = new ZwBaseWidget(m_window.youWin_mc));
         addWidget(this.m_rewardFrame = new ZwFrame(m_window.youWin_mc.prizeText_mc));
         addWidget(this.m_prizeBubble = new ZwFrame(m_window.youWin_mc.Prize_mc));
         this.m_prizeBubble.addWidget(this.m_rewardIcon = new FarmIcon(m_window.youWin_mc.Prize_mc.icon_mc));
         this.m_rewardFrame.addWidget(this.m_rewardName = new ZwTextField(m_window.youWin_mc.prizeText_mc.itemTitle_tf));
         this.m_rewardFrame.addWidget(this.m_rewardQuantity = new ZwTextField(m_window.youWin_mc.prizeText_mc.multiplier_tf));
         addWidget(this.m_collectionChipsFrame = new PrizeMachineChipFrame(m_window.slots_mc));
         this.setupCollectionChips();
         this.toggleFreeSpin();
         if(this.m_freeSpin.visible)
         {
            freeSpinBurst = new ZwBaseWidget(m_window.freeplay_mc.effect_mc);
            addWidget(freeSpinBurst);
            (freeSpinBurst.element as MovieClip).play();
         }
         this.addBackgroundPrizes();
         (this.m_prizeFrame.element as MovieClip).addEventListener("open_prize",this.playOpenSound);
      }
      
      private function addBackgroundPrizes() : void
      {
         var prizeIcon:FarmIcon = null;
         var prizeBall:ZwFrame = null;
         var rewardsList:XMLList = null;
         var reward:XML = null;
         var rewardName:String = null;
         var rewarItem:FarmItem = null;
         var prizesFrame:ZwFrame = new ZwFrame(m_window.prizes_mc);
         addWidget(prizesFrame);
         var prizeIcons:Vector.<FarmIcon> = new Vector.<FarmIcon>();
         var i:* = 0;
         while(m_window.prizes_mc.hasOwnProperty("prize" + i + "_mc"))
         {
            prizeBall = new ZwFrame(m_window.prizes_mc["prize" + i + "_mc"]);
            prizeIcon = new FarmIcon(m_window.prizes_mc["prize" + i + "_mc"].icon_mc);
            prizeIcons.push(prizeIcon);
            prizeBall.addWidget(prizeIcon);
            prizesFrame.addWidget(prizeBall);
            i++;
         }
         var xmlConfiguration:XML = Global.farmGameSettingsManager.getFeatureXML("prizemachine");
         var rewardsArray:Array = new Array();
         if(xmlConfiguration)
         {
            rewardsList = xmlConfiguration.rewards[0].reward;
            for each(reward in rewardsList)
            {
               rewardName = reward.@name;
               rewarItem = Global.farmGameSettingsManager.getFarmItemByName(rewardName);
               if(rewarItem != null)
               {
                  rewardsArray.push(rewarItem.icon);
               }
            }
         }
         var displayRewards:int = int(rewardsArray.length);
         var freeGifts:Array = FreeGiftSelectionWindow.freeGifts;
         if(freeGifts != null)
         {
            freeGifts = freeGifts.filter(this.isBuildingPart);
         }
         var replacements:* = 0;
         for(i = int(Math.max(0,prizeIcons.length - displayRewards)); i > 0; i--)
         {
            if(freeGifts != null && freeGifts[replacements] != null)
            {
               rewardsArray.push((freeGifts[replacements++] as FarmItem).icon);
            }
            else
            {
               rewardsArray.push(Global.getAssetURL(FREE_SPIN_ASSET));
            }
         }
         rewardsArray.sort(this.randomSort);
         for(i = 0; i < prizeIcons.length; i++)
         {
            prizeIcon = prizeIcons[i];
            prizeIcon.loadIcon(rewardsArray[i]);
         }
      }
      
      private function randomSort(objA:Object, objB:Object) : int
      {
         return Math.round(Math.random() * 3) - 1;
      }
      
      private function isBuildingPart(element:*, index:int, array:Array) : Boolean
      {
         var farmItem:FarmItem = element as FarmItem;
         return farmItem.className == "BuildingPart";
      }
      
      private function playOpenSound(event:Event = null) : void
      {
         if(this.m_rarePrizeAwarded)
         {
            SoundManager.playSound(SOUND_COLLECTION_PRIZE);
            this.m_rarePrizeAwarded = false;
         }
         else
         {
            SoundManager.playSound(SOUND_PRIZE_AWARDED);
         }
      }
      
      private function onMoreInfo(event:Event) : void
      {
         var timed:Boolean = PrizeMachineWindow.isTimedVariant();
         var zlocKey:String = timed ? "PrizeMachine_WhatIsThis_timed" : "PrizeMachine_WhatIsThis_untimed";
         var message:String = ZLocUtils.t("Dialogs",zlocKey,{"spinCost":PrizeMachineWindow.getSpinCost()});
         var whatIsThis:GenericPopup = new GenericPopup(message);
         UI.displayPopup(whatIsThis,false,"PrizeMachineWhatIsThis",true);
      }
      
      private function onBuyPrize(event:Event) : void
      {
         var buyTransaction:TGenericTransaction = null;
         var freeSpins:int = Global.player.getActionCount(PRIZE_MACHINE_FREE_SPIN);
         var canSpin:Boolean = false;
         if(freeSpins > 0)
         {
            canSpin = true;
            Global.player.setActionCount(PRIZE_MACHINE_FREE_SPIN,freeSpins - 1);
            FarmStatsManager.count(STAT_COUNTER,"game_spin","free");
            FarmStatsManager.count(STAT_COUNTER,"surface_motd","click","free");
         }
         else if(Global.player.cash >= PrizeMachineWindow.getSpinCost())
         {
            canSpin = true;
            Global.player.cash -= PrizeMachineWindow.getSpinCost();
            FarmStatsManager.count(STAT_COUNTER,"game_spin","paid");
            FarmStatsManager.count(STAT_COUNTER,"surface_motd","click","paid_" + PrizeMachineWindow.getSpinCost());
         }
         if(canSpin)
         {
            this.m_freeSpin.visible = false;
            this.m_playButton.visible = false;
            this.m_buyButton.visible = true;
            m_closeButton.visible = true;
            if(this.m_clearAnimation)
            {
               (this.m_prizeFrame.element as MovieClip).play();
               (this.m_prizeBubble.element as MovieClip).play();
            }
            (this.m_prizeFrame.element as MovieClip).gotoAndStop(0);
            (this.m_prizeBubble.element as MovieClip).gotoAndStop(0);
            this.m_playButton.enabled = false;
            this.m_buyButton.enabled = false;
            buyTransaction = new TGenericTransaction("PrizeMachineService","buyPrizeMachineBall",this.onPrizeResult);
            TransactionManager.addTransaction(buyTransaction,true);
            this.m_loading.visible = true;
            m_closeButton.enabled = false;
            (this.m_spinnerAnimation.element as MovieClip).play();
            SoundManager.playSound(SOUND_MACHINE_CRANK);
         }
         else
         {
            UI.displayImpulseBuyPopup(ImpulseBuy.TYPE_CASH,"impulseBuyPrizeMachine");
         }
      }
      
      private function onPrizeResult(result:Object) : void
      {
         var rewardsVector:Vector.<Object> = null;
         var currencyType:String = null;
         var currencyIcon:String = null;
         var farmItem:FarmItem = null;
         var quantity:int = 0;
         var grandPrize:FarmItem = null;
         SoundManager.playSound(SOUND_PRIZE_DROP);
         this.m_clearAnimation = true;
         this.m_playButton.enabled = true;
         this.m_buyButton.enabled = true;
         this.m_prizeBubble.visible = true;
         this.m_loading.visible = false;
         m_closeButton.enabled = true;
         (this.m_spinnerAnimation.element as MovieClip).stop();
         if(result != null && result.hasOwnProperty("prize") && result.prize != null && Boolean(result.prize.hasOwnProperty("type")))
         {
            rewardsVector = new Vector.<Object>();
            rewardsVector.push(result.prize);
            UserRewardUtil.grantUserRewards(rewardsVector);
            switch(result.prize.type)
            {
               case QuestConstants.REWARD_CASH_FROM_PRIZE_MACHINE:
                  this.m_rarePrizeAwarded = true;
                  this.m_rewardQuantity.visible = true;
                  this.m_rewardQuantity.text = result.prize.value;
                  this.m_rewardIcon.loadIcon(Global.getAssetURL(FARM_CASH_ICON),this.onPrizeIconLoaded);
                  this.m_rewardName.text = ZLocUtils.t("FarmGame","Currency_FarmCash");
                  break;
               case QuestConstants.REWARD_WORLD_CURRENCY:
                  this.m_rarePrizeAwarded = true;
                  currencyType = result.prize.hasOwnProperty("unit") ? result.prize.unit : Currency.JADE;
                  currencyIcon = Currency.getIcon(currencyType);
                  if(currencyIcon != null)
                  {
                     this.m_rewardIcon.loadIcon(Global.getAssetURL(currencyIcon),this.onPrizeIconLoaded);
                  }
                  this.m_rewardQuantity.visible = true;
                  this.m_rewardQuantity.text = result.prize.value;
                  this.m_rewardName.text = ZLocUtils.t("FarmGame",currencyType);
                  break;
               case QuestConstants.REWARD_PRIZE_MACHINE_CHIP:
                  FarmStatsManager.count(STAT_COUNTER,"collection_award","chip");
                  this.m_rarePrizeAwarded = true;
                  this.m_rewardQuantity.visible = false;
                  this.m_rewardIcon.loadIcon(Global.getAssetURL(COLLECTION_CHIP_ASSET));
                  this.m_rewardName.text = "Collection Chip";
                  this.setupCollectionChips();
                  break;
               case QuestConstants.REWARD_GRANT_ITEM:
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(result.prize.value);
                  quantity = result.prize.hasOwnProperty("quantity") ? int(result.prize.quantity) : 1;
                  if(farmItem != null)
                  {
                     this.m_rewardIcon.loadIcon(farmItem.icon,this.onPrizeIconLoaded);
                     this.m_rewardName.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
                     this.m_rewardQuantity.visible = quantity > 1;
                     this.m_rewardQuantity.text = "x" + quantity.toString();
                  }
                  break;
               case QuestConstants.REWARD_BUILDABLE_PART:
                  farmItem = Global.farmGameSettingsManager.getFarmItemByCode(result.prize.value);
                  quantity = result.prize.hasOwnProperty("quantity") ? int(result.prize.quantity) : 1;
                  if(farmItem != null)
                  {
                     this.m_rewardIcon.loadIcon(farmItem.icon,this.onPrizeIconLoaded);
                     this.m_rewardName.text = ZLocUtils.tk_pk_asTitle(farmItem.friendlyName);
                     this.m_rewardQuantity.visible = quantity > 1;
                     this.m_rewardQuantity.text = "x" + quantity.toString();
                     Global.player.addGift(farmItem.name,"0",quantity);
                  }
                  break;
               case QuestConstants.REWARD_PRIZE_MACHINE_FREE_SPIN:
                  this.m_rewardQuantity.visible = false;
                  this.m_rewardIcon.loadIcon(Global.getAssetURL(FREE_SPIN_ASSET));
                  this.m_rewardName.text = "Free Spin";
            }
            if(result.prize.type == QuestConstants.REWARD_PRIZE_MACHINE_CHIP && result.hasOwnProperty("collectionPrize"))
            {
               grandPrize = Global.farmGameSettingsManager.getFarmItemByName(result.collectionPrize);
               if(grandPrize)
               {
                  this.m_showToaster = false;
                  Global.player.addGift(grandPrize.name);
                  this.m_rarePrizeAwarded = true;
                  FarmStatsManager.count(STAT_COUNTER,"collection_award",grandPrize.name,grandPrize.cash.toString());
                  FeatureOptionsManager.getInstance().setFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE,null);
                  UI.showMessage(ZLocUtils.t("Dialogs","prizemachine_grandPrize_message",{"prizeName":ZLocUtils.tk_pk_asTitle(grandPrize.friendlyName)}),UI.BUTTON_LAYOUT_OK,null,null,false);
                  this.m_collectionChipsFrame.displayGrandPrize();
                  this.m_collectionChipsFrame.playCollectionPrizeAnimation();
                  this.setupCollectionChips();
               }
            }
            (this.m_prizeFrame.element as MovieClip).gotoAndPlay(0);
            this.toggleFreeSpin();
         }
      }
      
      private function onPrizeIconLoaded(event:Event = null) : void
      {
      }
      
      private function setupCollectionChips() : void
      {
         var prizeMachineData:Object = FeatureOptionsManager.getInstance().getFeatureOption(FeatureOptionsManager.PRIZE_MACHINE,FeatureOptionsManager.PRIZE_MACHINE);
         var chipsArray:Array = new Array();
         var collectionChips:int = prizeMachineData != null && prizeMachineData.hasOwnProperty("collection_chip") ? int(prizeMachineData.collection_chip) : 0;
         var collected:Boolean = false;
         for(var i:int = 0; i < 6; i++)
         {
            collected = i < collectionChips;
            chipsArray.push({"collected":collected});
         }
         this.m_collectionChipsFrame.items = chipsArray;
      }
      
      private function toggleFreeSpin() : void
      {
         var freeSpins:int = Global.player.getActionCount(PRIZE_MACHINE_FREE_SPIN);
         if(freeSpins > 0)
         {
            this.m_freeSpin.visible = true;
            this.m_buyButton.visible = false;
            this.m_playButton.visible = true;
            m_closeButton.visible = false;
         }
         else
         {
            this.m_freeSpin.visible = false;
            this.m_buyButton.visible = true;
            this.m_playButton.visible = false;
            m_closeButton.visible = true;
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         FarmStatsManager.count(STAT_COUNTER,"surface_motd","cancel");
         if(this.m_showToaster && !Global.player.getSeenSessionFlag("prize_machine_toaster"))
         {
            ToasterManager.getInstance().add(new PrizeMachineToasterWindow());
            Global.player.setSeenSessionFlag("prize_machine_toaster");
         }
         super.onClose(event);
      }
   }
}


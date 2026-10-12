package Widgets.Windows.Crafting
{
   import Classes.Constants.WorldsConstants;
   import Classes.crafting.CraftingStatsManager;
   import Classes.crafting.PendingReward;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.SoundManager;
   import Engine.Utilities;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Buttons.ZwButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.MarketRewardFriendFrame;
   import Widgets.Frames.Crafting.MarketRewardItemFrame;
   import Widgets.Windows.FarmWindow;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MarketRewardSocialWindow extends FarmWindow
   {
      
      protected var m_page:int = 0;
      
      protected var m_distinctUsers:Array;
      
      protected var m_rewardPoints:int = 0;
      
      public function MarketRewardSocialWindow()
      {
         super("assets/dialogs/FV_MarketStall_FriendReward.swf");
         this.computeRewardPointsAndDistinctUsers();
      }
      
      protected function computeRewardPointsAndDistinctUsers() : void
      {
         var thisReward:PendingReward = null;
         var rewards:Array = Global.player.craftingState.pendingRewards;
         var totalBushels:int = 0;
         var totalRewards:int = 0;
         this.m_distinctUsers = new Array();
         for(var i:int = 0; i < rewards.length; i++)
         {
            thisReward = rewards[i];
            if(!thisReward.claimed)
            {
               if(this.m_distinctUsers.indexOf(thisReward.visitorUid) < 0 && Global.friendManager.getFriendData(thisReward.visitorUid) != null)
               {
                  this.m_distinctUsers.push(thisReward.visitorUid);
               }
               totalBushels += thisReward.count;
               totalRewards++;
            }
         }
         this.m_rewardPoints = totalRewards;
      }
      
      override protected function postLoadComplete() : void
      {
         CraftingManager.getInstance().hideAllMarketRewardIndicators();
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","MarketRewardSocialDialog_Title",{
            "quantity":this.m_distinctUsers.length,
            "friendword":ZLocUtils.tk("Achievements","helpfriends_word","",this.m_distinctUsers.length)
         })));
         var pendingRewards:Array = Global.player.craftingState.pendingRewards;
         addWidget(new ZwButton(m_window.leftArrow_bt,this.onPageLeft),false);
         addWidget(new ZwButton(m_window.rightArrow_bt,this.onPageRight),pendingRewards.length > 5);
         addWidget(new MarketRewardFriendFrame(m_window.friendSlot_0_mc));
         addWidget(new MarketRewardFriendFrame(m_window.friendSlot_1_mc));
         addWidget(new MarketRewardFriendFrame(m_window.friendSlot_2_mc));
         addWidget(new MarketRewardFriendFrame(m_window.friendSlot_3_mc));
         addWidget(new MarketRewardFriendFrame(m_window.friendSlot_4_mc));
         this.update();
         addWidget(new ZwTextField(m_window.title2_tf,ZLocUtils.t("Crafting","MarketRewardSocialDialog_Claim")));
         var coinString:String = Utilities.formatNumber(CraftingManager.getInstance().getCoinRewardForRewardPoints(this.m_rewardPoints));
         addWidget(new MarketRewardItemFrame(m_window.slot_0_mc,Global.getAssetURL("assets/consumables/consume_coins_icon.png"),ZLocUtils.t("Crafting","MarketRewardDialog_RewardCoin",{
            "quantity":coinString,
            "coinword":ZLocUtils.tk("Dialogs","Coin_word","",CraftingManager.getInstance().getCoinRewardForRewardPoints(this.m_rewardPoints))
         }),this.onSelectCoinClicked));
         var fuelString:String = Utilities.formatNumber(CraftingManager.getInstance().getFuelRewardForRewardPoints(this.m_rewardPoints));
         addWidget(new MarketRewardItemFrame(m_window.slot_1_mc,Global.getAssetURL("assets/hud/FV_fuelSmallIcon_100x100.png"),ZLocUtils.t("Crafting","MarketRewardDialog_RewardFuel",{
            "quantity":fuelString,
            "plotword":ZLocUtils.tk("Items","plotCategory_friendlyName","",CraftingManager.getInstance().getFuelRewardForRewardPoints(this.m_rewardPoints))
         }),this.onSelectFuelClicked));
         var xpString:String = Utilities.formatNumber(CraftingManager.getInstance().getXpRewardForRewardPoints(this.m_rewardPoints));
         addWidget(new MarketRewardItemFrame(m_window.slot_2_mc,Global.getAssetURL("assets/consumables/consume_xp_icon.png"),ZLocUtils.t("Crafting","MarketRewardDialog_RewardXP",{"quantity":xpString}),this.onSelectXpClicked));
         addWidget(new FarmAnimatedTextButton(m_window.leaveStall_bt,ZLocUtils.t("Crafting","MarketRewardDialog_ReturnToStall"),this.onCloseCallback));
      }
      
      protected function update() : void
      {
         var uid:String = null;
         var count:String = null;
         var currentRewardIndex:int = 0;
         var pendingRewards:Array = Global.player.craftingState.pendingRewards;
         for(var i:int = 0; i < 5; i++)
         {
            uid = null;
            count = null;
            currentRewardIndex = i + this.m_page * 5;
            if(pendingRewards.length > currentRewardIndex)
            {
               uid = pendingRewards[currentRewardIndex].visitorUid;
               count = pendingRewards[currentRewardIndex].count;
            }
            (getWidget(m_window["friendSlot_" + i + "_mc"]) as MarketRewardFriendFrame).update(uid,count);
         }
         (getWidget(m_window.leftArrow_bt) as ZwButton).visible = this.m_page > 0;
         (getWidget(m_window.rightArrow_bt) as ZwButton).visible = this.m_page < int(pendingRewards.length / 5);
      }
      
      public function onPageLeft(event:Event) : void
      {
         if(this.m_page > 0)
         {
            --this.m_page;
         }
         this.update();
      }
      
      public function onPageRight(event:Event) : void
      {
         if(this.m_page < int(Global.player.craftingState.pendingRewards.length / 5))
         {
            ++this.m_page;
         }
         this.update();
      }
      
      protected function onCloseCallback(evt:MouseEvent) : void
      {
         close();
      }
      
      protected function onSelectCoinClicked(evt:MouseEvent) : void
      {
         this.handleRewardSelected(CraftingConstants.REWARD_PICK_COINS);
      }
      
      protected function onSelectFuelClicked(evt:MouseEvent) : void
      {
         if(Global.world.getEquipment() == null && Global.worldManager.currentWorldType == WorldsConstants.WORLD_ID_HOME)
         {
            UI.displayMessage(ZLocUtils.t("Dialogs","MustOwnTractor"),GenericPopup.TYPE_OK,null,"",true);
         }
         else
         {
            Global.hud.flashFuelBar(2);
            Global.hud.highlightFuel();
            this.handleRewardSelected(CraftingConstants.REWARD_PICK_FUEL);
         }
      }
      
      protected function onSelectXpClicked(evt:MouseEvent) : void
      {
         this.handleRewardSelected(CraftingConstants.REWARD_PICK_XP);
      }
      
      protected function handleRewardSelected(rewardChosen:int) : void
      {
         CraftingStatsManager.recordRewardChosen(rewardChosen);
         CraftingManager.getInstance().spendRewardPoints(this.m_rewardPoints,rewardChosen);
         SoundManager.chooseAndPlaySound(["money1","money2","money3"]);
         close();
      }
   }
}


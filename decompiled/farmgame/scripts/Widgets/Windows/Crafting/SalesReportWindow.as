package Widgets.Windows.Crafting
{
   import Classes.CraftingCottageBuilding;
   import Classes.crafting.RecipeItem;
   import Classes.feed.CraftingCottageFeed;
   import Classes.util.ZLocUtils;
   import Engine.Managers.TransactionManager;
   import Managers.Crafting.CraftingConstants;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Transactions.TCottageHistorySeen;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Crafting.SalesReportFrame;
   import Widgets.Windows.FarmWindow;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class SalesReportWindow extends FarmWindow
   {
      
      private var m_cottage:CraftingCottageBuilding;
      
      private var m_friendMC:MovieClip;
      
      private var m_coinMC:MovieClip;
      
      private var m_xpMC:MovieClip;
      
      private var m_friendFrame:ZwFrame;
      
      private var m_coinFrame:ZwFrame;
      
      private var m_xpFrame:ZwFrame;
      
      private var m_share_bt:FarmAnimatedButton;
      
      private var m_cancel_bt:FarmAnimatedButton;
      
      private var m_feed_tf:ZwTextField;
      
      public function SalesReportWindow(cottage:CraftingCottageBuilding)
      {
         this.m_cottage = cottage;
         super("assets/dialogs/FV_Craft_salesReport.swf");
      }
      
      override protected function postLoadComplete() : void
      {
         var friendsSold:Number;
         var coinsGained:Number;
         var xpGained:Number;
         var m_levelUpFeedInfo:Object = null;
         var recipeItem:RecipeItem = null;
         super.postLoadComplete();
         this.m_friendMC = m_window.friendRewardCell_mc;
         this.m_friendFrame = new ZwFrame(this.m_friendMC);
         friendsSold = this.m_cottage.transactionHistory.friendsSold;
         coinsGained = this.m_cottage.transactionHistory.coinsGained;
         xpGained = this.m_cottage.transactionHistory.xpGained;
         this.m_friendFrame.addWidget(new ZwTextField(this.m_friendMC.generic_tf,ZLocUtils.t("Crafting","SalesReport_YouSoldTo")));
         this.m_friendFrame.addWidget(new ZwTextField(this.m_friendMC.generic1_tf,friendsSold.toString()));
         this.m_friendFrame.addWidget(new ZwTextField(this.m_friendMC.generic2_tf,ZLocUtils.t("Crafting","SalesReport_Friends")));
         addWidget(this.m_friendFrame);
         this.m_coinMC = m_window.coinRewardCell_mc;
         this.m_coinFrame = new ZwFrame(this.m_coinMC);
         this.m_coinFrame.addWidget(new ZwTextField(this.m_coinMC.generic_tf,ZLocUtils.t("Crafting","SalesReport_YouMade")));
         this.m_coinFrame.addWidget(new ZwTextField(this.m_coinMC.generic1_tf,coinsGained.toString()));
         this.m_coinFrame.addWidget(new ZwTextField(this.m_coinMC.generic2_tf,ZLocUtils.t("Crafting","SalesReport_Coins")));
         addWidget(this.m_coinFrame);
         this.m_xpMC = m_window.xpRewardCell_mc;
         this.m_xpFrame = new ZwFrame(this.m_xpMC);
         this.m_xpFrame.addWidget(new ZwTextField(this.m_xpMC.generic_tf,ZLocUtils.t("Crafting","SalesReport_YouMade")));
         this.m_xpFrame.addWidget(new ZwTextField(this.m_xpMC.generic1_tf,xpGained.toString()));
         this.m_xpFrame.addWidget(new ZwTextField(this.m_xpMC.generic2_tf,ZLocUtils.t("Crafting","SalesReport_XP")));
         addWidget(this.m_xpFrame);
         addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t("Crafting","SalesReport_PopupTitle")));
         addWidget(new ZwTextField(m_window.generic_tf,ZLocUtils.t("Crafting","SalesReport_WhileYouWereGone")));
         addWidget(new SalesReportFrame(m_window.salesReport_mc,this.m_cottage,false));
         m_levelUpFeedInfo = this.m_cottage.transactionHistory.getLevelUpFeedInfo();
         if(m_levelUpFeedInfo != null && m_levelUpFeedInfo.hasOwnProperty(CraftingConstants.LOGDATA_REWARD_LINK))
         {
            recipeItem = Global.craftConfigSettings.getRecipeById(m_levelUpFeedInfo[CraftingConstants.LOGDATA_RECIPE_ID]);
            this.m_share_bt = new FarmAnimatedButton(m_window.share_bt,function(e:Event):void
            {
               startLevelUpFeedFlow(recipeItem,m_levelUpFeedInfo[CraftingConstants.LOGDATA_REWARD_LINK]);
            });
            this.m_cancel_bt = new FarmAnimatedButton(m_window.cancel_bt,onClose);
            this.m_feed_tf = new ZwTextField(m_window.feed_tf,ZLocUtils.t("Crafting","SalesReport_LevelUpFeed",{"itemRecipe":ZLocUtils.tk_pk(recipeItem.friendlyName + "_recipe")}));
            addWidget(this.m_share_bt);
            addWidget(this.m_cancel_bt);
            addWidget(this.m_feed_tf);
         }
         else
         {
            addWidget(new FarmAnimatedTextButton(m_window.okay_bt,ZLocUtils.t("Crafting","General_Okay"),onClose));
         }
      }
      
      private function startLevelUpFeedFlow(recipeItem:RecipeItem, recipeLink:String) : void
      {
         var recipeLevel:Number = Global.player.craftingState.craftingSkillState.getRecipeStateById(recipeItem.id).level;
         var localizationObj:Object = {
            "item":recipeItem.friendlyName,
            "level":recipeLevel,
            "cottageName":CraftingManager.getInstance().getCottageFriendlyNameByCraft(this.m_cottage.craftType)
         };
         var feed:CraftingCottageFeed = new CraftingCottageFeed("CraftingCottage_recipe_levelup",recipeLink,localizationObj);
         feed.setImage(recipeItem.image);
         close();
         feed.publish();
         FarmStatsManager.count("Crafting","Feed","CraftingCottage_recipe_levelup","share");
      }
      
      override protected function onShow() : void
      {
         super.onShow();
         var t:TCottageHistorySeen = new TCottageHistorySeen(this.m_cottage.craftType);
         TransactionManager.addTransaction(t,false);
      }
   }
}


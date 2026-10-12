package Widgets.Windows.Crafting
{
   import Classes.Constants.QuestConstants;
   import Classes.FeatureBuilding;
   import Classes.crafting.RecipeItem;
   import Display.UI;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Base.ZwBaseWidget;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class HangingGardensCraftingShopWindow extends PizzashopWindow
   {
      
      public static const HANGING_GARDENS_CRAFTSHOP_OPEN:String = "hanging_gardens_craftshop_open";
      
      public static const HANGING_GARDENS_CRAFTSHOP_CLOSE:String = "hanging_gardens_craftshop_close";
      
      private static const BUCKET_OF_TROWELS_RECIPE_ID:String = "bucket_trowels";
      
      private static const HANGING_GARDENS_REWARD_DIALOG:String = "assets/dialogs/xhg/FV_xhg_craftshopRewards.swf";
      
      private static const TUTORIAL_SEEN_FLAG:String = "hanging_gardens_craftshop_tutorial_seen_flag";
      
      public static const HANGING_GARDENS:String = "hanginggardenscraftingshopbuilding";
      
      private var m_FTUEMovieClip:MovieClip;
      
      public function HangingGardensCraftingShopWindow(building:FeatureBuilding, featureName:String = "hanginggardenscraftingshopbuilding")
      {
         super(building,featureName);
         Global.world.dispatchEvent(new Event(HANGING_GARDENS_CRAFTSHOP_OPEN));
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(!Global.player.getSeenFlag(TUTORIAL_SEEN_FLAG))
         {
            this.displayTutorial();
         }
      }
      
      override protected function onClose(event:Event) : void
      {
         Global.world.dispatchEvent(new Event(HANGING_GARDENS_CRAFTSHOP_CLOSE));
         super.onClose(event);
      }
      
      public function displayTutorial() : void
      {
         this.pressMoreInfo();
         if(m_window.ftue_mc)
         {
            TransactionManager.addTransaction(new TGenericTransaction("HangingGardensService","awardFtueTrowels"));
            this.m_FTUEMovieClip = m_window.ftue_mc;
            addWidget(new ZwBaseWidget(m_window.ftue_mc));
            if(this.m_FTUEMovieClip.make_btn)
            {
               addWidget(new FarmButton(this.m_FTUEMovieClip.make_btn,this.firstFTUEClick));
            }
         }
      }
      
      private function firstFTUEClick(event:Event) : void
      {
         this.m_FTUEMovieClip.gotoAndStop(2);
         if(this.m_FTUEMovieClip.finish_btn)
         {
            addWidget(new FarmButton(this.m_FTUEMovieClip.finish_btn,this.secondFTUEClick));
         }
      }
      
      private function secondFTUEClick(event:Event) : void
      {
         removeWidget(this.m_FTUEMovieClip);
         Global.player.setSeenFlag(TUTORIAL_SEEN_FLAG);
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(BUCKET_OF_TROWELS_RECIPE_ID);
         Global.player.updateWorldCurrency(QuestConstants.REWARD_TROWELS,recipeItem.worldCurrencyRewards.value);
         UI.displayPopup(new HangingGardensCraftingShopRewardWindow(HANGING_GARDENS_REWARD_DIALOG,recipeItem));
      }
      
      override public function onEndClaimFinishedRecipes(result:Object) : void
      {
         super.onEndClaimFinishedRecipes(result);
      }
   }
}


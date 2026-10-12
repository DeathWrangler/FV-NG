package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureBuilding;
   import Classes.MystreeNursery;
   import Classes.ZItem.FarmItem;
   import Classes.crafting.RecipeItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.TutorialUI;
   import Managers.Crafting.CraftingManager;
   import Managers.FarmStatsManager;
   import Managers.MystreeNurseryManager;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedCashButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.MystreeNurseryFrame;
   import Widgets.TextFields.FarmTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.text.TextField;
   
   public class MystreeNurseryWindow extends FarmWindow
   {
      
      private static const GET_BY_FEED_ITEM:String = "vwyl";
      
      private static const WINDOW_NAME:String = "mystreeNursery";
      
      private static const NO_OF_MYSTREES:int = 9;
      
      private static const TREE_PREFIX:String = "treecount_";
      
      private static const MYSTREE_FTUE_FLAG:String = "MystreeFTUE";
      
      private var m_tree_bt:FarmAnimatedButton;
      
      private var m_speedup_bt:FarmAnimatedCashButton;
      
      private var m_craft_bt:FarmAnimatedTextButton;
      
      private var m_awesome_bt:FarmAnimatedTextButton;
      
      private var m_craft_mc:MovieClip;
      
      private var m_plots:MystreeNurseryFrame;
      
      private var m_treeCollection:MovieClip;
      
      private var m_building:MystreeNursery;
      
      private var m_sunshineCount_tf:ZwTextField;
      
      private var m_treecollection_subtitle_tf:ZwTextField;
      
      private var m_ask_bt:FarmAnimatedTextButton;
      
      private var m_whatIsThis_mc:FarmAnimatedButton;
      
      public function MystreeNurseryWindow(building:MystreeNursery)
      {
         this.m_building = building;
         var dialogConfig:Object = this.m_building.getItem().getDialogConfig("storage");
         if(dialogConfig != null && dialogConfig.path != "")
         {
            super(dialogConfig.path);
         }
         if(!Global.player.getSeenFlag(MYSTREE_FTUE_FLAG))
         {
            this.howDoesThisWorkClick(null);
            MystreeNurseryManager.getInstance().initFeature();
            Global.player.setSeenFlag(MYSTREE_FTUE_FLAG);
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var item:FarmItem = null;
         var rainbowButterfly:ZwWidget = null;
         var feedLimitSeconds:Number = NaN;
         var replacements:Object = null;
         var craftingManager:CraftingManager = null;
         var ingredientConfig:Object = null;
         var recipeItem:RecipeItem = null;
         super.postLoadComplete();
         if(m_window.hasOwnProperty("title_tf"))
         {
            addWidget(new ZwTextField(m_window.title_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_title")),true);
         }
         if(m_window.hasOwnProperty("subtitle_tf"))
         {
            addWidget(new ZwTextField(m_window.subtitle_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_subtitle")),true);
         }
         if(m_window.hasOwnProperty("subtitle2_tf"))
         {
            addWidget(new ZwTextField(m_window.subtitle2_tf,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_subtitle2")),true);
         }
         if(m_window.hasOwnProperty("craft_mc"))
         {
            this.m_craft_mc = m_window.craft_mc;
            if(m_window.craft_mc.hasOwnProperty("bucketcount_tf"))
            {
               addWidget(this.m_sunshineCount_tf = new ZwTextField(m_window.craft_mc.bucketcount_tf,""),true);
               this.m_sunshineCount_tf.text = MystreeNurseryManager.getInstance().getNumberOfBuckets();
            }
            if(m_window.craft_mc.hasOwnProperty("craftbucket_bt"))
            {
               this.m_craft_bt = addWidget(new FarmAnimatedTextButton(m_window.craft_mc.craftbucket_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_craftbucket"),this.clickCraft),true) as FarmAnimatedTextButton;
            }
            this.m_craft_mc.visible = true;
         }
         if(m_window.hasOwnProperty("view_bt"))
         {
            this.m_tree_bt = addWidget(new FarmAnimatedButton(m_window.view_bt,this.openTreeWindow),true) as FarmAnimatedButton;
         }
         if(m_window.hasOwnProperty("speed_bt"))
         {
            this.m_speedup_bt = addWidget(new FarmAnimatedCashButton(m_window.speed_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"SeedDispenser_SpeedUp"),MystreeNurseryManager.SPEEDUP_COST.toString(),this.onSpeedUp),true) as FarmAnimatedCashButton;
         }
         if(m_window.hasOwnProperty("whatisthis_mc"))
         {
            this.m_whatIsThis_mc = addWidget(new FarmAnimatedTextButton(m_window.whatisthis_mc,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"HowDoesThisWork"),this.howDoesThisWorkClick),true) as FarmAnimatedButton;
         }
         if(m_window.plantplot_mc)
         {
            addWidget(this.m_plots = new MystreeNurseryFrame(m_window.plantplot_mc,this),true);
         }
         if(m_window.collection_mc)
         {
            this.m_treeCollection = m_window.collection_mc;
            if(m_window.collection_mc.hasOwnProperty("awesome_bt"))
            {
               this.m_awesome_bt = addWidget(new FarmAnimatedTextButton(m_window.collection_mc.awesome_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_awesome"),this.clickAwesome),true) as FarmAnimatedTextButton;
            }
            if(m_window.collection_mc.hasOwnProperty("subtitle1_tf"))
            {
               this.m_treecollection_subtitle_tf = addWidget(new ZwTextField(m_window.collection_mc.subtitle1_tf),true) as ZwTextField;
            }
            this.refreshTreeCollection();
            this.m_treeCollection.visible = false;
         }
         if(m_window.subtitle3_tf)
         {
            item = Global.farmGameSettingsManager.getFarmItemByCode(GET_BY_FEED_ITEM);
            addWidget(new FarmTextField(m_window.subtitle3_tf,item.friendlyTitle),true);
         }
         if(m_window.rainbowbutterfly_mc)
         {
            rainbowButterfly = addWidget(new ZwWidget(m_window.rainbowbutterfly_mc),true) as ZwWidget;
            feedLimitSeconds = Global.craftConfigSettings.getRecipeIngredientRequestFeedLimitSeconds();
            replacements = {};
            replacements["time"] = FarmGameUtil.toFriendlyTime(feedLimitSeconds,true);
            rainbowButterfly.attachTooltip(new FarmTextTooltip(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_askTooltip",replacements)));
         }
         if(m_window.askbutterfly_bt)
         {
            this.m_ask_bt = addWidget(new FarmAnimatedTextButton(m_window.askbutterfly_bt,"Ask",this.onAskClick),true) as FarmAnimatedTextButton;
            craftingManager = CraftingManager.getInstance();
            ingredientConfig = new Object();
            ingredientConfig[RecipeItem.ITEM_CODE] = GET_BY_FEED_ITEM;
            recipeItem = Global.craftConfigSettings.getRecipeById(MystreeNurseryManager.SB_CRAFTING_ID);
            if(!craftingManager.canPublishGetByFeedIngredient(recipeItem,ingredientConfig))
            {
               this.m_ask_bt.enabled = false;
            }
         }
         FarmStatsManager.count("Mystree","Main UI","view");
      }
      
      private function howDoesThisWorkClick(e:Event = null) : void
      {
         var prefixUrl:String = this.m_building.getItem().prefixUrl;
         var callback:Function = null;
         if(!Global.player.getSeenFlag(MYSTREE_FTUE_FLAG))
         {
            callback = this.openTreeWindow;
         }
         TutorialUI.displayBuildingTutorialWindow(this.m_building as FeatureBuilding,prefixUrl,false,callback);
      }
      
      private function openTreeWindow(e:Event = null) : void
      {
         this.m_whatIsThis_mc.visible = false;
         m_closeButton.visible = false;
         this.m_treeCollection.visible = true;
         this.refreshTreeCollection();
         FarmStatsManager.count("Mystree","Collection","view");
      }
      
      private function refreshTreeCollection() : void
      {
         var i:int = 0;
         var count:int = 0;
         var isAllCollected:Boolean = true;
         var treeCount:int = 0;
         if(this.m_treeCollection)
         {
            for(i = 0; i < NO_OF_MYSTREES; i++)
            {
               count = MystreeNurseryManager.getInstance().getClaimedCount(i);
               if(count == 0)
               {
                  isAllCollected = false;
               }
               else
               {
                  treeCount++;
               }
               if(count > 999)
               {
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_maxShowtreeCount");
               }
               else
               {
                  (this.m_treeCollection[TREE_PREFIX + i] as TextField).text = count.toString();
               }
            }
            if(!isAllCollected)
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_subtitle1_incomplete",{"treeCount":treeCount});
            }
            else
            {
               this.m_treecollection_subtitle_tf.text = ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,WINDOW_NAME + "_subtitle1_complete");
            }
         }
      }
      
      private function onSpeedUp(e:Event = null) : void
      {
         MystreeNurseryManager.getInstance().speedUpSaplings();
         this.m_plots.refresh();
      }
      
      private function clickCraft(e:Event = null) : void
      {
         close();
         MystreeNurseryManager.getInstance().showCraftingWindowWithItem();
      }
      
      private function clickAwesome(e:Event = null) : void
      {
         this.m_treeCollection.visible = false;
         m_closeButton.visible = true;
         this.m_whatIsThis_mc.visible = true;
      }
      
      override protected function release() : void
      {
         this.m_building = null;
         this.m_tree_bt = null;
         this.m_craft_bt = null;
         this.m_speedup_bt = null;
         this.m_awesome_bt = null;
         this.m_craft_mc = null;
         this.m_plots = null;
         this.m_treeCollection = null;
         this.m_sunshineCount_tf = null;
         super.release();
      }
      
      public function updateSunshineBuckets() : void
      {
         if(this.m_sunshineCount_tf)
         {
            this.m_sunshineCount_tf.text = MystreeNurseryManager.getInstance().getNumberOfBuckets();
         }
      }
      
      public function enableSpeedUp(enable:Boolean) : void
      {
         this.m_speedup_bt.enabled = enable;
      }
      
      public function onAskClick(e:Event = null) : void
      {
         this.m_ask_bt.enabled = false;
         var craftingManager:CraftingManager = CraftingManager.getInstance();
         var ingredientConfig:Object = new Object();
         ingredientConfig[RecipeItem.ITEM_CODE] = GET_BY_FEED_ITEM;
         var recipeItem:RecipeItem = Global.craftConfigSettings.getRecipeById(MystreeNurseryManager.SB_CRAFTING_ID);
         craftingManager.startGetByFeedIngredientFlow(recipeItem,ingredientConfig);
      }
   }
}


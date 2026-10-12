package Widgets.Windows
{
   import Classes.Constants.Experiments;
   import Classes.StorageBuilding;
   import Classes.WishingFountainFeatureBuilding;
   import Classes.util.ZLocUtils;
   import Display.GenericXMLDialog;
   import Display.UI;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class WishingFountainWindow extends MultiStageBuildingDialog
   {
      
      private static const COIN_PACKAGE_SIZE:int = 2000;
      
      private static const DECO_STAGES_AHEAD:int = 2;
      
      private var m_stageText:ZwTextField;
      
      private var m_pointsText:ZwTextField;
      
      private var m_upgradeText:ZwTextField;
      
      public function WishingFountainWindow(building:StorageBuilding)
      {
         super(building);
      }
      
      public static function openMakeRecipeWindow(buildingName:String, recipeClicked:String = null) : void
      {
         var recipeId:String = null;
         var craftShopName:String = null;
         var prompt:GenericXMLDialog = null;
         craftShopName = Global.farmGameSettingsManager.getAttribute(buildingName + "_craftshop","craftingworkshop_finished");
         var craftshopOpened:Boolean = false;
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_MINIRECIPE_WINDOW) >= Experiments.SINGLE_CONTROL_VALID_VARIANT_START)
         {
            if(recipeClicked != null)
            {
               recipeId = recipeClicked;
            }
            else
            {
               recipeId = Global.farmGameSettingsManager.getAttribute(buildingName + "_defaultRecipe","8Hj");
            }
            CraftingManager.getInstance().openCraftingUiForRecipe(recipeId,craftShopName);
         }
         else
         {
            recipeId = Global.farmGameSettingsManager.getAttribute(buildingName + "_defaultRecipe","8Hj");
            if(CraftingManager.getInstance().showCraftingWindowForRecipe(recipeId))
            {
               craftshopOpened = true;
            }
            if(!craftshopOpened)
            {
               prompt = new GenericXMLDialog(null,null,null,Global.farmGameSettingsManager.getImageByName(craftShopName,"icon",false),100,100,ZLocUtils.t_pk("Dialogs:" + buildingName + "_SurfaceCraftShop_Message"),null,true,ZLocUtils.t_pk("Dialogs:PrizedPig_SurfaceCraftShop_Button"),function(event:Event):void
               {
                  Global.world.enterForcePlaceMode(craftShopName,true,0,false,false,{"suppressGiftRepop":true});
               });
               UI.displayPopup(prompt,true,"",true);
            }
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var level:int = 0;
         var buildingName:String = null;
         super.postLoadComplete();
         if(m_window["main_mc"].hasOwnProperty("topbanner_mc"))
         {
            m_window["main_mc"].topbanner_mc.visible = true;
            level = m_featureBuilding.storageLevel;
            buildingName = this.m_featureBuilding.getItemName();
            this.m_stageText = new ZwTextField(m_window["main_mc"].topbanner_mc.stage_tf,ZLocUtils.t("Dialogs",buildingName + "_topbanner",{"storageLevel":level}));
            this.m_pointsText = new ZwTextField(m_window["main_mc"].topbanner_mc.points_tf,"+" + level * COIN_PACKAGE_SIZE);
            this.m_upgradeText = new ZwTextField(m_window["main_mc"].topbanner_mc.body_tf,ZLocUtils.t("Dialogs",buildingName + "_topbanner_upgrade"));
            addWidget(this.m_stageText);
            addWidget(this.m_pointsText);
            addWidget(this.m_upgradeText);
            if(level > 1)
            {
               this.m_upgradeText.visible = false;
            }
            else
            {
               this.m_stageText.visible = false;
               this.m_pointsText.visible = false;
               m_window["main_mc"].topbanner_mc.icon_mc.visible = false;
            }
         }
      }
      
      override protected function setupDecorationStage(curLevel:int, maxLevel:int) : void
      {
         var fountainBuilding:WishingFountainFeatureBuilding = null;
         var lastBuildState:int = 0;
         var decorationCurrentStage:int = 0;
         curLevel = curLevel > maxLevel ? maxLevel : curLevel;
         if(m_featureBuilding is WishingFountainFeatureBuilding)
         {
            fountainBuilding = m_featureBuilding as WishingFountainFeatureBuilding;
            lastBuildState = fountainBuilding.getNearestBuildState();
            decorationCurrentStage = fountainBuilding.builtStates.indexOf(lastBuildState) + DECO_STAGES_AHEAD;
            if(m_window.main_mc.hasOwnProperty("decorationStage" + decorationCurrentStage + "_mc"))
            {
               m_window.main_mc["decorationStage" + decorationCurrentStage + "_mc"].visible = true;
            }
            else
            {
               decorationCurrentStage = fountainBuilding.builtStates.length + 1;
               if(m_window.main_mc.hasOwnProperty("decorationStage" + decorationCurrentStage + "_mc"))
               {
                  m_window.main_mc["decorationStage" + decorationCurrentStage + "_mc"].visible = true;
               }
            }
         }
         else if(m_window.main_mc.hasOwnProperty("decorationStage" + curLevel + "_mc"))
         {
            m_window.main_mc["decorationStage" + curLevel + "_mc"].visible = true;
         }
         else if(m_window.main_mc.hasOwnProperty(DEFAULT_UI_BACKGROUND))
         {
            m_window.main_mc["decorationStage1_mc"].visible = true;
         }
      }
   }
}


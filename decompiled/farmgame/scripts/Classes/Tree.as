package Classes
{
   import AvatarMode.AMHarvest;
   import Classes.Constants.CollectionsConstants;
   import Classes.Constants.Experiments;
   import Classes.NeighborActions.NeighborActionConstants;
   import Classes.Quest.PrerequisiteUtility;
   import Classes.instagrow.InstagrowUtils;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Classes.World;
   import GameMode.GMAirplaneFly;
   import Managers.CollectionsManager;
   import Managers.FarmStatsManager;
   import Managers.FeatureBuildingSurfacingManager;
   import Managers.InstagrowHelper;
   import Managers.ItemMembershipManager;
   import Managers.RetentionMasterManager;
   import Widgets.Windows.BuildingSurfaceWindow;
   import Widgets.Windows.Mastery.MasteryWindow;
   import Widgets.Windows.OrchardSurfaceWindow;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.utils.getQualifiedClassName;
   
   public class Tree extends SimpleHarvestableResource
   {
      
      public static const STATE_BARE:String = "bare";
      
      public static const STATE_MATURE:String = "mature";
      
      private const TREE:String = "tree";
      
      protected const APPLY_GROW:String = "applyInstantGrow";
      
      private var m_ghostFXFilter:ColorMatrixFilter = new ColorMatrixFilter([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0]);
      
      private var m_isGhosted:Boolean = false;
      
      public function Tree(itemName:String = null)
      {
         super(itemName);
         m_objectType = WorldObjectTypes.TREE;
         m_typeName = this.TREE;
      }
      
      override public function isUsingPerPixelPick() : Boolean
      {
         return true;
      }
      
      override public function showMenu() : void
      {
         if(!inQueue())
         {
            m_menuItems = [{
               "label":ZLocUtils.t("FarmGame","Move"),
               "action":MOVE_OBJECT
            }];
            if(Global.player.level >= Global.farmGameSettingsManager.getInt("sellLockLevel"))
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Sell"),
                  "action":SELL_OBJECT
               });
            }
            if(Boolean(Global.selectedAvatar) && isHarvestable())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","Harvest"),
                  "action":HARVEST_OBJECT
               });
            }
            if(InstagrowHelper.playerCanSeeFeature())
            {
               m_menuItems.push({
                  "label":ZLocUtils.t("FarmGame","ApplyInstantGrow"),
                  "action":this.APPLY_GROW
               });
            }
            super.showMenu();
            FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_open","tree","","","User opens context menu from tree");
         }
         else
         {
            displayStatus(ZLocUtils.t("FarmGame","AnimalBusy"));
         }
      }
      
      override protected function getMasteryWindowType() : String
      {
         return MasteryWindow.TYPE_TREE;
      }
      
      override protected function getCurrentImage() : ItemImage
      {
         var imageName:String = null;
         var disallowAltAnimation:Boolean = false;
         this.ghost(false);
         var image:ItemImage = null;
         if(m_item != null)
         {
            if(this.m_altGraphic != "")
            {
               switch(m_altGraphic)
               {
                  case "ghost":
                     this.ghost(true);
                     break;
                  default:
                     m_overlayXML = Global.farmGameSettingsManager.getOverlayByName(this.m_altGraphic);
                     conditionallyAttachOverlay();
               }
            }
            imageName = getCurrentImageName();
            imageName = this.postProcessImageName(imageName);
            disallowAltAnimation = !(m_outer is World);
            image = this.getCachedImage(imageName,disallowAltAnimation);
         }
         return image;
      }
      
      override public function postProcessImageName(name:String) : String
      {
         var imageName:String = name;
         if(m_altGraphic != "ghost")
         {
            imageName = super.postProcessImageName(name);
         }
         else
         {
            imageName = findTerrainPrefix() + imageName;
         }
         return imageName;
      }
      
      override public function onUpdate(delta:Number) : void
      {
         super.onUpdate(delta);
         if(this.m_altGraphic == "ghost")
         {
            if(m_displayObject.filters.length == 0)
            {
               this.ghost(true);
            }
         }
         else if(this.m_isGhosted)
         {
            this.ghost(false);
         }
      }
      
      override public function showHighlight(isShowing:Boolean, color:uint = 16755200) : void
      {
         if(m_displayObject)
         {
            if(isShowing)
            {
               m_displayObject.filters = m_filters.concat([createHighlightGlowFilter(color,1)]);
            }
            else
            {
               m_displayObject.filters = m_filters.concat([]);
            }
         }
      }
      
      override public function set highlightAlpha(value:Number) : void
      {
         m_highlight.alpha = value;
         m_displayObject.filters = m_filters.concat([m_highlight]);
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         var message:String = null;
         var dialog:GenericPopup = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            if(item.action == this.APPLY_GROW)
            {
               if(Global.world.addGameMode(new GMAirplaneFly(),true) == false)
               {
                  message = ZLocUtils.t("Dialogs","InstantGrow_OnlyOnePlaneAtATime");
                  dialog = new GenericPopup(message,GenericPopup.TYPE_OK);
                  UI.displayPopup(dialog);
               }
               FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","tree",InstagrowUtils.INSTA_GROW_COUNTER,"","User opens context menu from tree, clicks instant_grow");
            }
            else
            {
               super.onMenuClick(event);
               FarmStatsManager.sample(100,InstagrowUtils.INSTA_GROW_COUNTER,"context_menu_click","tree","all_other_options","","User opens context menu from tree, clicks all_other_options");
            }
         }
      }
      
      override public function onClick() : void
      {
         onMouseOut();
         if(!hasValidId())
         {
            showObjectBusy();
         }
         else if(Boolean(Global.selectedAvatar) && Boolean(isHarvestable()) && !Global.worldManager.isVisiting())
         {
            Global.selectedAvatar.getStateMachine().addState(new AMHarvest(Global.selectedAvatar,this),true);
         }
         else
         {
            super.onClick();
         }
      }
      
      override protected function buildTooltipText() : String
      {
         var harvestTimeVariant:int = 0;
         var growPercentage:int = 0;
         var toolTip:String = null;
         if(!Global.worldManager.isVisiting())
         {
            switch(state)
            {
               case STATE_RIPE:
                  toolTip = ZLocUtils.t("FarmGame","RipeTree",{"item":ZLocUtils.tk_pk(m_item.friendlyName)});
                  break;
               case STATE_BARE:
                  harvestTimeVariant = Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_HARVEST_TIME_2);
                  if(RetentionMasterManager.inMasterExperiment() && (harvestTimeVariant == 2 || harvestTimeVariant == 4))
                  {
                     toolTip = getHarvestTimeText();
                  }
                  else
                  {
                     growPercentage = getGrowPercentage();
                     toolTip = ZLocUtils.t("FarmGame","BareTree",{
                        "item":ZLocUtils.tk_pk(m_item.friendlyName),
                        "quantity":growPercentage
                     });
                  }
                  if(getQualifiedClassName(Global.world.getTopGameMode()) == "GameMode::GMDefault" && InstagrowHelper.playerCanSeeFeature())
                  {
                     toolTip += "\n" + ZLocUtils.t("FarmGame","ApplyInstantGrowHint");
                  }
            }
         }
         else
         {
            toolTip = m_item.friendlyTitle;
            if(VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION) && state == STATE_RIPE)
            {
               toolTip = ZLocUtils.t("FarmGame","AskToHarvest");
            }
         }
         return toolTip;
      }
      
      override public function harvest(energySource:int = 0, energy:Number = 0, showNoEnergyMessage:Boolean = true, updateBackend:Boolean = true, neighborId:String = "0") : Boolean
      {
         CollectionsManager.getInstance().executeCollectionAction(CollectionsConstants.ACTION_HARVEST_TREE,this as HarvestableResource,this.getPosition());
         if(!Global.worldManager.isVisiting() && Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_FLASH_TREE_HARVEST_ORCHARD_PROMO) > 1)
         {
            if(PrerequisiteUtility.checkPrereqByName(OrchardFeatureBuilding.ORCHARD_FEATUREBUILDING_ENABLED_PREREQ))
            {
               BuildingSurfaceWindow.conditionallyShowPrompt(this,FeatureBuildingSurfacingManager.TREE_SURFACING_KEYWORD,BuildingSurfaceWindow.ZLOC_PREFIX_ORCHARDS_NEW,BuildingSurfaceWindow.ZLOC_PREFIX_ORCHARDS_FULL);
            }
            else
            {
               OrchardSurfaceWindow.conditionallyShowPrompt(this);
            }
         }
         return super.harvest(energySource,energy,showNoEnergyMessage,updateBackend,neighborId);
      }
      
      override public function canBeClickedOnVisit() : Boolean
      {
         return this.isHarvestable() && VisitorManager.getInstance().canPerformAction(this,NeighborActionConstants.LIMIT_TYPE_FARM_ACTION);
      }
      
      override public function isHarvestableByNeighbors() : Boolean
      {
         return true;
      }
      
      protected function ghost(turnOn:Boolean) : void
      {
         if(m_displayObject != null)
         {
            if(turnOn)
            {
               this.m_isGhosted = true;
               m_filters = [this.m_ghostFXFilter];
            }
            else
            {
               m_filters = [];
               this.m_isGhosted = false;
            }
            m_displayObject.filters = m_filters;
         }
      }
      
      override public function onHarvestComplete(result:Object) : void
      {
         super.onHarvestComplete(result);
         ItemMembershipManager.conditionallyOnboard(ItemMembershipManager.FEATURE_NAME_TREE);
      }
   }
}


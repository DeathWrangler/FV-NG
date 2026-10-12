package Widgets.Frames.Crafting
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.GenericExpandSlotFrame;
   import Widgets.Windows.Crafting.CraftshopWindow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class CraftshopExpandFrame extends ZwFrame
   {
      
      private static const INDICATOR_PROPERY_PREFIX:String = "indicator_";
      
      protected var m_building:FeatureBuilding = null;
      
      protected var m_window:CraftshopWindow = null;
      
      private var m_featureName:String;
      
      private var m_genericExpandFrame:GenericExpandSlotFrame = null;
      
      private var m_expandClickBlockers:Array = null;
      
      private var m_expandDescription:ZwTextField = null;
      
      public function CraftshopExpandFrame(element:MovieClip, window:CraftshopWindow, building:FeatureBuilding, featureName:String = "")
      {
         var indicatorNum:int = 0;
         var indicatorProperty:String = null;
         this.m_featureName = featureName;
         this.m_window = window;
         super(element);
         this.m_building = building;
         this.m_genericExpandFrame = this.initGenericExpansionFrame(element);
         if(this.m_genericExpandFrame)
         {
            this.m_expandClickBlockers = new Array();
            indicatorNum = 0;
            indicatorProperty = INDICATOR_PROPERY_PREFIX + indicatorNum.toString() + "_mc";
            while(element.hasOwnProperty(indicatorProperty))
            {
               this.m_expandClickBlockers.push(addWidget(new ZwFrame(element[indicatorProperty])));
               indicatorNum++;
               indicatorProperty = INDICATOR_PROPERY_PREFIX + indicatorNum.toString() + "_mc";
            }
            if(element.close_bt)
            {
               addWidget(new FarmButton(element.close_bt,this.onCloseExpand));
            }
            if(element.expand_tf)
            {
               this.m_expandDescription = addWidget(new ZwTextField(element.expand_tf,"expand_tf")) as ZwTextField;
            }
         }
         else
         {
            this.visible = false;
         }
      }
      
      private function initGenericExpansionFrame(expandMC:MovieClip) : GenericExpandSlotFrame
      {
         var expandFrame:GenericExpandSlotFrame = null;
         var expansionItems:Array = this.m_building.expand.getExpandSlotData();
         if(expansionItems)
         {
            expandFrame = new GenericExpandSlotFrame(expandMC,expansionItems,this.m_window,this.m_building,this.m_building.expand);
            addWidget(expandFrame);
         }
         return expandFrame;
      }
      
      protected function onCloseExpand(event:MouseEvent) : void
      {
         this.m_window.showExpandFrame(false);
      }
      
      public function showExpandFrame(showPanel:Boolean) : void
      {
         if(this.m_genericExpandFrame)
         {
            if(showPanel)
            {
               this.m_genericExpandFrame.visible = true;
               this.m_expandDescription.text = CraftingManager.shouldUseNewCraftshopInFeature(this.m_featureName) ? ZLocUtils.t("Crafting","CraftingMainv2_Expansion_Description") : ZLocUtils.t("Crafting","CraftingMain_Expansion_Description");
               this.m_expandDescription.visible = true;
               this.hideAllExpandClickBlockers(this.m_building.storageLevel);
            }
            else
            {
               this.m_genericExpandFrame.visible = false;
               this.hideAllExpandClickBlockers();
            }
         }
         else
         {
            this.visible = false;
         }
      }
      
      public function isExpandFrameVisible() : Boolean
      {
         var result:Boolean = false;
         if(this.m_genericExpandFrame)
         {
            result = this.m_genericExpandFrame.visible;
         }
         return result;
      }
      
      private function hideAllExpandClickBlockers(butNotThisIndex:int = -1) : void
      {
         var iMC:int = 0;
         if(this.m_expandClickBlockers)
         {
            for(iMC = 0; iMC < this.m_expandClickBlockers.length; iMC++)
            {
               this.m_expandClickBlockers[iMC].visible = iMC == butNotThisIndex ? true : false;
            }
         }
      }
   }
}


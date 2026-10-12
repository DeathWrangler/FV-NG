package Widgets.Frames.UGC
{
   import Classes.UGC.IUGCMapResource;
   import Classes.UGC.UGCConstants;
   import Classes.UGC.UGCItemLayerDefinition;
   import Classes.UGC.UGCUtil;
   import Classes.ZItem.IUGCItem;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Menu.MenuItem;
   import flash.display.DisplayObject;
   
   public class UGCDecoItemEditorFrame extends UGCItemEditorFrame
   {
      
      private var m_infoTextField:ZwTextField;
      
      public function UGCDecoItemEditorFrame(element:DisplayObject, assetFrame:UGCItemPaintingFrame, ugcItem:IUGCItem, customizeItem:IUGCMapResource)
      {
         super(element,assetFrame,ugcItem,customizeItem);
      }
      
      override protected function createItemLayerEditorFrame() : void
      {
         m_itemSelector = new UGCDecoItemLayerEditorFrame(m_element.grid_mc,m_ugcItemState);
         m_itemSelector.addEventListener(UGCConstants.EVENT_SELECT_ITEM,onItemClick);
         m_nameHandleHash["grid_mc"] = m_frameManager.addWidget(addWidget(m_itemSelector,false));
      }
      
      override protected function createTabMenuItem(tabConfig:Object, name:String) : MenuItem
      {
         return new MenuItem(tabConfig,UGCUtil.t2(this.getGameSettingsFeatureName(),name));
      }
      
      override protected function setItemSelectorLayer(ugcLayer:UGCItemLayerDefinition) : void
      {
         super.setItemSelectorLayer(ugcLayer);
         this.setInstructions(ugcLayer.name);
      }
      
      override protected function setInstructionsText(type:String) : void
      {
         if(type == "color")
         {
            this.setInstructions(type);
         }
         else
         {
            super.setInstructionsText(type);
         }
      }
      
      private function setInstructions(name:String) : void
      {
         if(!this.m_infoTextField)
         {
            if(ObjectUtil.pathExists(m_element,"subtabinstructions_tf"))
            {
               this.m_infoTextField = new ZwTextField(m_element.subtabinstructions_tf,"");
               addWidget(this.m_infoTextField);
            }
         }
         if(this.m_infoTextField)
         {
            if(ZLocUtils.hasString("Dialogs","UGCDeco_subtab_info_" + name))
            {
               this.m_infoTextField.text = ZLocUtils.t("Dialogs","UGCDeco_subtab_info_" + name);
               m_instructions.text = "";
            }
            else
            {
               this.m_infoTextField.text = "";
            }
         }
      }
   }
}


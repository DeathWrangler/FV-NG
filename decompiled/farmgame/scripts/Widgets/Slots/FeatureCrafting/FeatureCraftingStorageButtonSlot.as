package Widgets.Slots.FeatureCrafting
{
   import Classes.Constants.ZLocConstants;
   import Classes.FeatureCrafting.FeatureCraftingInventory;
   import Classes.ImageLoader;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingContentsWindow;
   import Widgets.Windows.FeatureCrafting.FeatureCraftingStorageWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingStorageButtonSlot extends ZwSlotFrame
   {
      
      private var m_data:FeatureCraftingInventory;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_infoTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_currentContentWindow:FeatureCraftingContentsWindow;
      
      private var m_location:String = "";
      
      private var m_slotBGIcon:DisplayObject;
      
      public function FeatureCraftingStorageButtonSlot(element:DisplayObject, location:String = "")
      {
         var buttonBGSlot:String = null;
         super(element);
         this.m_location = location;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf)) as ZwTextField;
         this.m_infoTextField = addWidget(new ZwTextField(m_element.info_tf)) as ZwTextField;
         this.m_countTextField = addWidget(new ZwTextField(m_element.count_tf)) as ZwTextField;
         if(this.m_location != "" && TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION,this.m_location))
         {
            TemplateUIUtility.applyExpansionGlowFilter(m_element.name_tf);
            TemplateUIUtility.applyExpansionGlowFilter(m_element.count_tf);
         }
         if(m_element.hasOwnProperty("mc_Button"))
         {
            if(this.m_location != "")
            {
               buttonBGSlot = Global.worldSettingsManager.getSlotBGImagePath("Button100",this.m_location);
               if(buttonBGSlot)
               {
                  ImageLoader.getInstance(Global.getAssetURL(buttonBGSlot)).getContent(this.onSlotUrlLoaded);
                  if(this.m_slotBGIcon)
                  {
                     m_element["mc_Button"].addChild(this.m_slotBGIcon);
                     m_element["mc_Button"].visible = true;
                  }
               }
            }
         }
         (m_element as MovieClip).addEventListener(MouseEvent.CLICK,this.onClick);
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBGIcon = dispObj;
      }
      
      override public function release() : void
      {
         this.m_nameTextField = null;
         this.m_infoTextField = null;
         this.m_countTextField = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data as FeatureCraftingInventory;
         if(this.m_data)
         {
            this.refresh();
         }
      }
      
      public function get data() : FeatureCraftingInventory
      {
         return this.m_data;
      }
      
      public function refresh() : void
      {
         var infoTextKey:String = null;
         if(this.m_data)
         {
            this.m_nameTextField.text = this.m_data.friendlyTitle;
            this.m_nameTextField.visible = true;
            infoTextKey = "StorageButton_InfoMessage_" + this.m_data.name;
            if(ZLocUtils.hasString(ZLocConstants.PKG_FEATURE_CRAFTING,infoTextKey))
            {
               this.m_infoTextField.text = ZLocUtils.t(ZLocConstants.PKG_FEATURE_CRAFTING,infoTextKey);
               this.m_infoTextField.visible = true;
            }
            this.refreshCount();
         }
      }
      
      public function refreshCount() : void
      {
         if(this.m_data)
         {
            this.m_countTextField.text = this.m_data.currentCount + "/" + this.m_data.currentLimit;
            this.m_countTextField.visible = true;
         }
      }
      
      private function onClick(event:MouseEvent) : void
      {
         if(this.m_data)
         {
            FeatureCraftingStorageWindow.display(this.m_data);
            if(this.currentContentWindow)
            {
               this.currentContentWindow.closeCurrentNPCWindow();
            }
         }
      }
      
      public function get currentContentWindow() : FeatureCraftingContentsWindow
      {
         return this.m_currentContentWindow;
      }
      
      public function set currentContentWindow(currentContentWindow:FeatureCraftingContentsWindow) : void
      {
         this.m_currentContentWindow = currentContentWindow;
      }
   }
}


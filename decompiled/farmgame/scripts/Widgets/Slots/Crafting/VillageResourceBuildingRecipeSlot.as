package Widgets.Slots.Crafting
{
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.Crafting.VillageResourceBuildingWindow;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class VillageResourceBuildingRecipeSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:VillageResourceBuildingWindow = null;
      
      protected var m_data:Object = null;
      
      private var m_icon:FarmIcon = null;
      
      public function VillageResourceBuildingRecipeSlot(element:DisplayObject, parentWindow:VillageResourceBuildingWindow)
      {
         this.m_parentWindow = parentWindow;
         super(element);
         if(m_element.hasOwnProperty("icon_mc"))
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_icon.setSmoothing(true);
            this.m_icon.registerEventListener(MouseEvent.CLICK,this.onSlotClick);
         }
      }
      
      override public function release() : void
      {
         this.m_data = null;
         this.m_icon = null;
         this.m_parentWindow = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         if(this.m_data)
         {
            if(this.m_icon != null)
            {
               this.m_icon.loadIcon(Global.getAssetURL(this.m_data.image));
               this.m_icon.visible = true;
               if(this.m_icon.tooltip)
               {
                  this.m_icon.detachTooltip();
               }
               this.m_icon.attachTooltip(new FarmTextTooltip(this.m_data.name));
            }
         }
      }
      
      private function onSlotClick(event:MouseEvent) : void
      {
         if(Boolean(this.m_data) && Boolean(this.m_data.recipeId != "") && Boolean(this.m_parentWindow))
         {
            if(Boolean(this.m_icon) && Boolean(this.m_icon.tooltip))
            {
               this.m_icon.tooltip.release();
               this.m_icon.detachTooltip();
            }
            this.m_parentWindow.updateSelectedRecipe(this.m_data.recipeId);
         }
      }
   }
}


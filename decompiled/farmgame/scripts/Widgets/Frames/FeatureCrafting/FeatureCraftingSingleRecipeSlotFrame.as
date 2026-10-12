package Widgets.Frames.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class FeatureCraftingSingleRecipeSlotFrame extends FeatureCraftingRecipeSlotContainerFrame
   {
      
      private static const ICON_SIZE:int = 100;
      
      private var m_closeButton:FarmAnimatedButton;
      
      private const CLOSE_BUTTON:String = "close_bt";
      
      private const ICON_MC:String = "icon_mc";
      
      private const TITLE_TF:String = "title_tf";
      
      private const SLOT_MC:String = "slot_0_mc";
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_data:FeatureCraftingRecipe;
      
      private var m_station:FeatureCraftingStation;
      
      public function FeatureCraftingSingleRecipeSlotFrame(element:DisplayObject)
      {
         super(element);
         if(m_element[this.TITLE_TF])
         {
            this.m_nameTextField = addWidget(new ZwTextField(m_element.title_tf,"Recipe Name")) as ZwTextField;
         }
         if(m_element.hasOwnProperty(this.CLOSE_BUTTON))
         {
            this.m_closeButton = new FarmAnimatedButton(m_element.close_bt,this.onCloseButton);
            addWidget(this.m_closeButton,true);
         }
         if(m_element.icon_mc)
         {
            this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
            this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
            this.m_icon.setSmoothing(true);
         }
      }
      
      private function onCloseButton(ev:MouseEvent) : void
      {
         this.toggleSingleRecipeFrame(false);
      }
      
      public function toggleSingleRecipeFrame(toggle:Boolean) : void
      {
         m_element.visible = toggle;
      }
      
      public function isSingleRecipeFrameOpen() : Boolean
      {
         return m_element.visible;
      }
      
      override public function refresh() : void
      {
         super.refresh();
         refreshDisplay();
      }
      
      public function set station(station:FeatureCraftingStation) : void
      {
         this.m_station = station;
      }
      
      public function get station() : FeatureCraftingStation
      {
         return this.m_station;
      }
      
      override public function set items(items:Array) : void
      {
         if(Boolean(items.length) && items[0] != null)
         {
            this.m_data = items[0];
            this.m_data.station = this.station;
            this.m_icon.loadIcon(this.m_data.station.iconUrl);
            this.m_icon.visible = true;
            this.m_nameTextField.text = this.m_data.station.friendlyTitle;
            this.m_nameTextField.visible = true;
            super.items = items;
         }
      }
   }
}


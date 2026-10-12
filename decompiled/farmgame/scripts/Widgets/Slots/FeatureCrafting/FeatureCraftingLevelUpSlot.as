package Widgets.Slots.FeatureCrafting
{
   import Classes.FeatureCrafting.FeatureCraftingNPC;
   import Classes.FeatureCrafting.FeatureCraftingRecipe;
   import Classes.FeatureCrafting.FeatureCraftingStation;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class FeatureCraftingLevelUpSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      public function FeatureCraftingLevelUpSlot(element:DisplayObject)
      {
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_icon.setSmoothing(true);
         this.m_nameTextField = addWidget(new ZwTextField(m_element.name_tf," ")) as ZwTextField;
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_nameTextField = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         var npc:FeatureCraftingNPC = null;
         var recipe:FeatureCraftingRecipe = null;
         var station:FeatureCraftingStation = null;
         super.populate(data);
         if(data)
         {
            if(data is FeatureCraftingNPC)
            {
               npc = data as FeatureCraftingNPC;
               this.m_icon.loadIcon(Global.getAssetURL(npc.iconUrl));
               this.m_icon.visible = true;
               this.m_nameTextField.text = npc.friendlyTitle;
               this.m_nameTextField.visible = true;
            }
            else if(data is FeatureCraftingRecipe)
            {
               recipe = data as FeatureCraftingRecipe;
               this.m_icon.loadIcon(Global.getAssetURL(recipe.iconUrl));
               this.m_icon.visible = true;
               this.m_nameTextField.text = recipe.friendlyTitle;
               this.m_nameTextField.visible = true;
            }
            else if(data is FeatureCraftingStation)
            {
               station = data as FeatureCraftingStation;
               this.m_icon.loadIcon(Global.getAssetURL(station.iconUrl));
               this.m_icon.visible = true;
               this.m_nameTextField.text = station.friendlyTitle;
               this.m_nameTextField.visible = true;
            }
         }
      }
   }
}


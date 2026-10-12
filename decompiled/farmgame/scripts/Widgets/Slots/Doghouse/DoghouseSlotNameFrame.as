package Widgets.Slots.Doghouse
{
   import Classes.FeatureBuilding;
   import Classes.breeding.MutableAnimalState;
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Windows.Breeding.BreedingRenameWindow;
   import Widgets.Windows.Doghouse.DoghouseContentsWindow;
   import com.adobe.serialization.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public final class DoghouseSlotNameFrame extends ZwFrame
   {
      
      public static const DEFAULT_FRAME:int = 1;
      
      public static const FEATURED_FRAME:int = 2;
      
      private var m_itemNameTextField:ZwTextField;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_renameButton:FarmAnimatedTextButton;
      
      private var m_animalState:MutableAnimalState;
      
      public function DoghouseSlotNameFrame(element:DisplayObject)
      {
         super(element);
         this.m_itemNameTextField = addWidget(new ZwTextField(m_element.itemCategory_tf,"")) as ZwTextField;
         this.m_nameTextField = addWidget(new ZwTextField(m_element.itemTitle_tf,"")) as ZwTextField;
         this.m_renameButton = addWidget(new FarmAnimatedTextButton(m_element.rename_bt,ZLocUtils.t("FarmGame","Rename"),this.onRenameButtonClick)) as FarmAnimatedTextButton;
      }
      
      override public function release() : void
      {
         this.m_animalState = null;
         this.m_itemNameTextField = null;
         this.m_nameTextField = null;
         this.m_renameButton = null;
         super.release();
      }
      
      public function populate(data:Object) : void
      {
         this.m_itemNameTextField.text = data.friendlyName;
         if(Boolean(data["metadata"]) && Boolean(data["metadata"]["key"]) && Boolean(data["metadata"]["data"]))
         {
            this.m_animalState = new MutableAnimalState(data["metadata"]["key"],com.adobe.serialization.json.JSON.decode(data["metadata"]["data"]),data["metadata"]["data"]);
            this.m_nameTextField.text = this.m_animalState.name;
         }
         else
         {
            this.m_nameTextField.text = "";
         }
         this.m_renameButton.visible = data.quantity > 0;
         if(data.isFeatured)
         {
            (m_element as MovieClip).gotoAndStop(FEATURED_FRAME);
         }
         else
         {
            (m_element as MovieClip).gotoAndStop(DEFAULT_FRAME);
         }
      }
      
      private function onRenameButtonClick(event:MouseEvent) : void
      {
         var parentWindow:DoghouseContentsWindow = null;
         var building:FeatureBuilding = null;
         if(this.m_renameButton.enabled)
         {
            this.m_renameButton.enabled = false;
            parentWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
            parentWindow.tintWindow();
            building = parentWindow.building;
            UI.displayPopup(new BreedingRenameWindow((m_parent as DoghouseSlot).mapResource,this.m_animalState,false,parentWindow.building,this.onRenameWindowClose),false);
         }
      }
      
      private function onRenameWindowClose(renamed:Boolean) : void
      {
         var parentWindow:DoghouseContentsWindow = getAncestorByClassType(DoghouseContentsWindow) as DoghouseContentsWindow;
         if(renamed)
         {
            parentWindow.refresh();
         }
         this.m_renameButton.enabled = true;
         parentWindow.untintWindow();
      }
   }
}


package Widgets.Slots.Pigo
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public final class PigoPrizeSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_itemName:String;
      
      private var m_count:int;
      
      private var m_isMysteryPrizesEnabled:Boolean;
      
      private var m_icon:FarmIcon;
      
      private var m_countTextField:ZwTextField;
      
      private var m_darkNameTextField:ZwTextField;
      
      private var m_darkBackgroundWidget:ZwWidget;
      
      private var m_lightNameTextField:ZwTextField;
      
      private var m_lightBackgroundWidget:ZwWidget;
      
      private var m_lightStatusFrame:ZwFrame;
      
      private var m_questionMarkWidget:ZwWidget;
      
      public function PigoPrizeSlot(element:DisplayObject, isMysteryPrizesEnabled:Boolean = false)
      {
         super(element);
         this.m_isMysteryPrizesEnabled = isMysteryPrizesEnabled;
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         this.m_countTextField = addWidget(new ZwTextField(m_element.multiplier_tf," ")) as ZwTextField;
         this.m_darkNameTextField = addWidget(new ZwTextField(m_element.greyText_tf," ")) as ZwTextField;
         this.m_darkBackgroundWidget = addWidget(new ZwWidget(m_element.darkBackground_mc)) as ZwWidget;
         this.m_lightNameTextField = addWidget(new ZwTextField(m_element.greenText_tf," ")) as ZwTextField;
         this.m_lightBackgroundWidget = addWidget(new ZwWidget(m_element.lightBackground_mc)) as ZwWidget;
         this.m_lightStatusFrame = addWidget(new ZwFrame(m_element.won_mc)) as ZwFrame;
         this.m_lightStatusFrame.addWidget(new ZwTextField(m_element.won_mc.won_tf,ZLocUtils.t("Dialogs","PigoWindow_PrizeSlot_Won")));
         this.m_questionMarkWidget = addWidget(new ZwFrame(m_element.questionMark_mc)) as ZwFrame;
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_itemName = data["itemName"];
         this.m_count = data["winCount"];
         this.refresh(true);
      }
      
      override public function release() : void
      {
         this.m_icon = null;
         this.m_countTextField = null;
         this.m_darkNameTextField = null;
         this.m_darkBackgroundWidget = null;
         this.m_lightNameTextField = null;
         this.m_lightBackgroundWidget = null;
         super.release();
      }
      
      private function refresh(isNewItem:Boolean = false) : void
      {
         var item:FarmItem = null;
         if(isNewItem)
         {
            item = Global.farmGameSettingsManager.getFarmItemByName(this.m_itemName);
            if(item)
            {
               this.m_icon.loadIcon(item.iconUrl);
               this.m_icon.visible = true;
               this.m_darkNameTextField.text = this.m_lightNameTextField.text = item.friendlyTitle;
            }
         }
         var count:int = this.m_count;
         if(count > 0)
         {
            this.m_countTextField.text = ZLocUtils.t("Dialogs","PigoWindow_PrizeSlot_Count",{"quantity":String(count)});
            this.m_countTextField.visible = true;
            this.m_icon.visible = true;
            this.m_lightNameTextField.visible = true;
            this.m_lightBackgroundWidget.visible = true;
            this.m_lightStatusFrame.visible = true;
            this.m_darkNameTextField.visible = false;
            this.m_darkBackgroundWidget.visible = false;
            this.m_questionMarkWidget.visible = false;
         }
         else
         {
            if(this.m_isMysteryPrizesEnabled)
            {
               this.m_questionMarkWidget.visible = true;
               this.m_darkNameTextField.visible = false;
               this.m_icon.visible = false;
            }
            else
            {
               this.m_darkNameTextField.visible = true;
               this.m_icon.visible = true;
               this.m_questionMarkWidget.visible = false;
            }
            this.m_darkBackgroundWidget.visible = true;
            this.m_countTextField.visible = false;
            this.m_lightNameTextField.visible = false;
            this.m_lightBackgroundWidget.visible = false;
            this.m_lightStatusFrame.visible = false;
         }
      }
      
      public function get itemName() : String
      {
         return this.m_itemName;
      }
      
      public function incrementCount() : void
      {
         ++this.m_count;
         this.refresh();
      }
      
      public function get count() : int
      {
         return this.m_count;
      }
   }
}


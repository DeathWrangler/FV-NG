package Widgets.Slots
{
   import Classes.ZItem.FarmItem;
   import Managers.OrderBoard.CarribeanInnovationManager;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.CarribeanInnovationFranchiseWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class CarribeanInnovationFranchiseTaskSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_owner:CarribeanInnovationFranchiseWindow;
      
      private var FIRST_TIME_DUMP_SEEN:String = "dremworldInnovationFirstTimeDump";
      
      private var m_checkmarkMc:MovieClip;
      
      private var m_hitWidget1:ZwWidget;
      
      private var NAME_ARRAY:Array = new Array("Vin","Jen","Mia","Joe","Tina","Kelly","Tsao","Cliff");
      
      private var ORDER_ARRAY:Array = new Array("m1","f1","f2","m2","f3","f4","m3","m4");
      
      private var m_nameTf:ZwTextField;
      
      public function CarribeanInnovationFranchiseTaskSlot(featureName:String, element:DisplayObject, window:CarribeanInnovationFranchiseWindow)
      {
         this.m_featureName = featureName;
         this.m_owner = window;
         super(element);
         if(m_element.hasOwnProperty("checkmark_mc"))
         {
            this.m_checkmarkMc = m_element.checkmark_mc as MovieClip;
            this.m_checkmarkMc.visible = true;
         }
         if(m_element.hasOwnProperty("name_tf"))
         {
            addWidget(this.m_nameTf = new ZwTextField(m_element["name_tf"],""));
            this.m_nameTf.visible = true;
         }
      }
      
      override public function populate(data:Object) : void
      {
         var itemName:String = null;
         var itemBox:FarmIcon = null;
         var item:FarmItem = null;
         var iconUrl:String = null;
         var tileCount:int = 0;
         this.m_data = data;
         itemName = "xcb_npccart_" + this.ORDER_ARRAY[this.m_data["rewardSlotNumber"] - 1];
         if(Boolean(m_element) && Boolean(m_element["slot_icon_mc"]))
         {
            itemBox = null;
            item = Global.farmGameSettingsManager.getFarmItemByName(itemName);
            addWidget(itemBox = new FarmIcon(m_element["slot_icon_mc"]));
            if(itemBox)
            {
               iconUrl = item.getImageByName(FarmItem.ICON_FEED);
               itemBox.loadIcon(iconUrl);
               itemBox.setIconSize(150,150);
               itemBox.visible = true;
            }
         }
         if(this.m_nameTf)
         {
            tileCount = int(this.m_data["rewardSlotNumber"]);
            this.m_nameTf.text = this.NAME_ARRAY[tileCount - 1];
            this.m_nameTf.visible = true;
         }
         this.m_checkmarkMc.visible = this.m_data["rewardSlotNumber"] <= this.m_data["tileUnlockCount"];
         this.m_hitWidget1 = new ZwFrame(m_element["slot_icon_mc"] as MovieClip);
         this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver());
         this.m_hitWidget1.registerEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut());
      }
      
      private function onMouseOver() : Function
      {
         return function(evt:MouseEvent):void
         {
            var tileNo:* = m_data["rewardSlotNumber"];
            if(tileNo > manager.getTileUnlockCount())
            {
               m_owner.setNPCText(m_checkmarkMc.visible,"Franchises give fame","Have a total of " + tileNo.toString() + " land tiles unlocked to license our Franchise to " + NAME_ARRAY[tileNo - 1] + " . Then you can collect " + (tileNo + (Global.player.getSeenFlag("Caribbean_LandBundle_unlocked") ? 10 : 0)).toString() + " Fame every 12 hours.");
            }
         };
      }
      
      private function get manager() : CarribeanInnovationManager
      {
         return CarribeanInnovationManager.getInstance(this.m_featureName);
      }
      
      private function onMouseOut() : Function
      {
         return function(evt:MouseEvent):void
         {
            m_owner.hideNpcText();
         };
      }
   }
}


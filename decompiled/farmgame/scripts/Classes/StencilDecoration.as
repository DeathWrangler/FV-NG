package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Managers.StatsManager;
   import GameMode.GMObjectMove;
   import Managers.StencilManager;
   import flash.events.MouseEvent;
   
   public class StencilDecoration extends Decoration implements IRotatable
   {
      
      protected static const SHOW_STENCIL:String = "showStencil";
      
      protected static const REMOVE_STENCIL:String = "removeStencil";
      
      protected const STATE_HORIZONTAL:String = "horizontal";
      
      protected const STATE_VERTICAL:String = "vertical";
      
      protected const STENCIL_ORIGINAL:String = "stencil";
      
      protected const STENCIL_FLIPPED:String = "stencilFlipped";
      
      public function StencilDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override protected function getMenuItems() : Array
      {
         var items:Array = null;
         return [{
            "label":ZLocUtils.t("FarmGame","Rotate"),
            "action":ROTATE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         },{
            "label":"Show Effect",
            "action":SHOW_STENCIL
         },{
            "label":"Remove Effect",
            "action":REMOVE_STENCIL
         },{
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         }];
      }
      
      override public function onDelete() : void
      {
         hideStencilEffect();
         super.onDelete();
      }
      
      override protected function canShowStoreMenuItem() : Boolean
      {
         return false;
      }
      
      override public function onSell() : void
      {
         super.onSell();
         hideStencilEffect();
      }
      
      override protected function getSellPrice() : int
      {
         return 0;
      }
      
      override public function allowDelete() : Boolean
      {
         return true;
      }
      
      override public function onObjectDrop() : void
      {
         super.onObjectDrop();
         this.showStencil();
      }
      
      override public function move() : void
      {
         Global.world.addGameMode(new GMObjectMove(this),false);
      }
      
      override public function setState(value:String) : void
      {
         state = value;
      }
      
      override public function getCurrentImageName() : String
      {
         return STATE_STATIC;
      }
      
      override public function setPlaced(placed:Boolean) : void
      {
         if(placed)
         {
            StencilManager.instance().onStencilPlace(this);
         }
         super.setPlaced(placed);
      }
      
      public function rotate(fromMoveTool:Boolean = true) : void
      {
         switch(this.state)
         {
            case this.STATE_VERTICAL:
               this.setState(this.STATE_HORIZONTAL);
               break;
            case this.STATE_HORIZONTAL:
            default:
               this.setState(this.STATE_VERTICAL);
         }
         this.showStencil();
         if(!fromMoveTool)
         {
            Global.world.addGameMode(new GMObjectMove(this,this.state),false);
         }
      }
      
      public function getCurrentStencilState() : String
      {
         switch(state)
         {
            case this.STATE_VERTICAL:
               return this.STENCIL_FLIPPED;
            case this.STATE_HORIZONTAL:
         }
         return this.STENCIL_ORIGINAL;
      }
      
      public function syncRotationChange() : void
      {
      }
      
      public function showStencil() : void
      {
         var itemImage:ItemImage = m_item.getCachedImage(this.getCurrentStencilState());
         if(!itemImage)
         {
            itemImage = m_item.getCachedImage(this.getCurrentStencilState());
         }
         showStencilEffect(itemImage);
      }
      
      public function canRotate() : Boolean
      {
         return true;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case SHOW_STENCIL:
                  this.showStencil();
                  StatsManager.count(StencilManager.instance().featureName,"totem_context_menu","enable","",Global.worldManager.currentWorldType);
                  break;
               case ROTATE_OBJECT:
                  this.rotate(false);
                  StatsManager.count(StencilManager.instance().featureName,"totem_context_menu","rotate","",Global.worldManager.currentWorldType);
                  break;
               case MOVE_OBJECT:
                  this.move();
                  StatsManager.count(StencilManager.instance().featureName,"totem_context_menu","move","",Global.worldManager.currentWorldType);
                  break;
               case SELL_OBJECT:
                  this.sell();
                  StatsManager.count(StencilManager.instance().featureName,"totem_context_menu","sell","",Global.worldManager.currentWorldType);
                  break;
               case REMOVE_STENCIL:
                  hideStencilEffect();
                  StatsManager.count(StencilManager.instance().featureName,"totem_context_menu","disable","",Global.worldManager.currentWorldType);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
   }
}


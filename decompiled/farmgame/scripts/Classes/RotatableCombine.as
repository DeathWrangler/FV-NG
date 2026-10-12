package Classes
{
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Managers.SoundManager;
   import GameMode.GMObjectMove;
   import flash.events.MouseEvent;
   
   public class RotatableCombine extends Combine implements IRotatable
   {
      
      public static const COMBINE:String = "combine";
      
      public static const Rotate:String = "Rotate";
      
      private static const NUM_PARTS:String = "numParts";
      
      protected const STATE_HORIZONTAL:String = "horizontal";
      
      protected const STATE_VERTICAL:String = "vertical";
      
      private const CAN_ROTATE_NOT_SET:int = 0;
      
      private const ROTATEABLE:int = 1;
      
      private const NOT_ROTATEABLE:int = 2;
      
      private var m_canRotate:int = 0;
      
      public function RotatableCombine(itemName:String = null, active:Boolean = false, upgradeParts:Number = 0)
      {
         super(itemName,active,upgradeParts);
         if(this.canRotate())
         {
            this.setState(this.STATE_HORIZONTAL);
         }
      }
      
      override protected function getMenuItems() : Array
      {
         var menuArray:Array = super.getMenuItems();
         menuArray.push({
            "label":ZLocUtils.t("FarmGame","Rotate"),
            "action":Rotate
         });
         return menuArray;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case MOVE_OBJECT:
                  this.move();
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               case VEHICLE_ACTION:
                  doCombineVehicleAction();
                  break;
               case HORN:
                  SoundManager.addSound(Combine.COMBINE_HORN_ID,Global.getAssetURL(Combine.COMBINE_HORN_SFX_ASSET));
                  SoundManager.playSound(Combine.COMBINE_HORN_ID);
                  break;
               case COMBINE_MORE_INFO:
                  doCombineMoreInfoAction();
                  break;
               case Rotate:
                  this.rotate(false);
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function getCurrentImageName() : String
      {
         var imageName:String = null;
         if(this.canRotate())
         {
            switch(state)
            {
               case this.STATE_HORIZONTAL:
                  imageName = "horizontal";
                  break;
               case this.STATE_VERTICAL:
                  imageName = "vertical";
                  break;
               default:
                  imageName = super.getCurrentImageName();
            }
         }
         else
         {
            imageName = super.getCurrentImageName();
         }
         return imageName;
      }
      
      override public function setState(value:String) : void
      {
         if(Boolean(m_item) && this.canRotate())
         {
            switch(value)
            {
               case this.STATE_VERTICAL:
                  setSize(m_item.sizeY,m_item.sizeX);
                  break;
               case this.STATE_HORIZONTAL:
               default:
                  setSize(m_item.sizeX,m_item.sizeY);
                  value = this.STATE_HORIZONTAL;
            }
         }
         super.setState(value);
      }
      
      override public function loadObject(data:Object) : void
      {
         if(!this.canRotate() && Boolean(data["state"]))
         {
            data["state"] = STATE_STATIC;
         }
         super.loadObject(data);
         if(this.canRotate())
         {
            this.setState(data.state);
         }
      }
      
      public function syncRotationChange() : void
      {
      }
      
      override protected function isRotated() : Boolean
      {
         var result:Boolean = false;
         if(this.canRotate())
         {
            result = state == this.STATE_VERTICAL;
         }
         else
         {
            result = super.isRotated();
         }
         return result;
      }
      
      override public function preDisableMove(oldState:String) : void
      {
         if(this.canRotate())
         {
            this.setState(oldState);
         }
         else
         {
            super.preDisableMove(oldState);
         }
      }
      
      public function rotate(fromMoveTool:Boolean = true) : void
      {
         var currentState:String = null;
         if(this.canRotate())
         {
            currentState = state;
            switch(currentState)
            {
               case this.STATE_VERTICAL:
                  this.setState(this.STATE_HORIZONTAL);
                  break;
               case this.STATE_HORIZONTAL:
               default:
                  this.setState(this.STATE_VERTICAL);
            }
            if(!fromMoveTool)
            {
               Global.world.addGameMode(new GMObjectMove(this,currentState),false);
            }
         }
      }
      
      public function canRotate() : Boolean
      {
         var hasHor:Boolean = false;
         var hasVert:Boolean = false;
         if(this.m_canRotate == this.CAN_ROTATE_NOT_SET && Boolean(m_item))
         {
            hasHor = m_item.displayLoader.hasImageNameDefined(this.STATE_HORIZONTAL);
            hasVert = m_item.displayLoader.hasImageNameDefined(this.STATE_VERTICAL);
            if(hasHor && hasVert)
            {
               this.m_canRotate = this.ROTATEABLE;
            }
            else
            {
               this.m_canRotate = this.NOT_ROTATEABLE;
            }
         }
         return this.m_canRotate == this.ROTATEABLE;
      }
   }
}


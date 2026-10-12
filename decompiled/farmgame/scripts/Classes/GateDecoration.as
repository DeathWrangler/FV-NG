package Classes
{
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Display.ContextMenuItem;
   import Engine.Classes.World;
   import Engine.Managers.TransactionManager;
   import Transactions.TMove;
   import flash.events.MouseEvent;
   
   public class GateDecoration extends MaskedDecoration
   {
      
      protected var m_isOpen:Boolean = false;
      
      protected const OPEN_OBJECT:String = "openObject";
      
      protected const CLOSE_OBJECT:String = "closeObject";
      
      protected var m_openCollisionFlagIndex:int = 0;
      
      protected var m_closedCollisionFlagIndex:int = 1;
      
      public function GateDecoration(itemName:String = null)
      {
         super(itemName);
      }
      
      override public function setItem(item:FarmItem) : void
      {
         super.setItem(item);
         this.m_openCollisionFlagIndex = m_item.getCollisionDataIndexByName("open");
         this.m_closedCollisionFlagIndex = m_item.getCollisionDataIndexByName("closed");
      }
      
      override protected function initializeParts(itemName:String = null) : void
      {
         var index:int = 0;
         var notMasked:Boolean = false;
         if(m_displayObject)
         {
            m_displayObject.alpha = 0;
         }
         if(itemName)
         {
            m_maskedParts = new Array(m_item.getNumberOfParts());
            notMasked = false;
            for(index = 0; index < m_maskedParts.length; index++)
            {
               if(index >= m_maskedParts.length - 2)
               {
                  notMasked = true;
               }
               m_maskedParts[index] = new MaskedDecorationPart(itemName,index,notMasked);
               (m_maskedParts[index] as MaskedDecorationPart).setMain(this);
               (m_maskedParts[index] as MaskedDecorationPart).setState(state);
               (m_maskedParts[index] as MaskedDecorationPart).setOuter(this.m_outer);
               (m_maskedParts[index] as MaskedDecorationPart).setPosition(m_position.x,m_position.y,m_position.z);
            }
            (m_maskedParts[m_maskedParts.length - 1] as MaskedDecorationPart).setImageSuffix("_closed");
            m_maskedPartsInitialized = true;
            if(m_outer)
            {
               this.attachAndDetachParts();
            }
         }
      }
      
      override public function setOuter(outer:World) : void
      {
         super.setOuter(outer);
         this.attachAndDetachParts();
      }
      
      override protected function getBackPart() : MaskedDecorationPart
      {
         var index:int = 0;
         var result:MaskedDecorationPart = null;
         if(this.m_isOpen)
         {
            index = m_maskedParts.length - 2;
         }
         else
         {
            index = m_maskedParts.length - 1;
         }
         if(m_maskedParts.length > 0 && m_maskedPartsInitialized)
         {
            result = m_maskedParts[index] as MaskedDecorationPart;
         }
         return result;
      }
      
      override protected function getMenuItems() : Array
      {
         var result:Array = [{
            "label":ZLocUtils.t("FarmGame","Rotate"),
            "action":ROTATE_OBJECT
         },{
            "label":ZLocUtils.t("FarmGame","Move"),
            "action":MOVE_OBJECT
         }];
         if(this.m_isOpen)
         {
            result.push({
               "label":ZLocUtils.t("FarmGame","Close"),
               "action":this.CLOSE_OBJECT
            });
         }
         else
         {
            result.push({
               "label":ZLocUtils.t("FarmGame","Open"),
               "action":this.OPEN_OBJECT
            });
         }
         result.push({
            "label":ZLocUtils.t("FarmGame","Sell"),
            "action":SELL_OBJECT
         });
         return result;
      }
      
      protected function open(newState:Boolean) : void
      {
         this.m_isOpen = newState;
         this.attachAndDetachParts();
         setState(state);
         setDisplayObjectDirty(true);
         this.conditionallyReattach();
         this.syncChanges();
      }
      
      override public function rotate(fromMoveTool:Boolean = true) : void
      {
         super.rotate(fromMoveTool);
         if(canRotate())
         {
            setDisplayObjectDirty(true);
            this.conditionallyReattach();
         }
      }
      
      private function attachAndDetachParts() : void
      {
         var index:int = 0;
         if(m_maskedPartsInitialized)
         {
            for(index = 0; index < m_maskedParts.length; index++)
            {
               (m_maskedParts[index] as MaskedDecorationPart).detach();
            }
            if(!this.m_isOpen)
            {
               (m_maskedParts[m_maskedParts.length - 1] as MaskedDecorationPart).attach();
            }
            else
            {
               for(index = 0; index < m_maskedParts.length - 1; index++)
               {
                  (m_maskedParts[index] as MaskedDecorationPart).attach();
               }
            }
         }
      }
      
      override public function conditionallyReattach(force:Boolean = false) : void
      {
         var index:int = 0;
         var needsRedraw:Boolean = force || m_transformDirty || m_displayObjectDirty || m_attachPosition == null;
         var temp:Boolean = m_maskedPartsInitialized;
         m_maskedPartsInitialized = false;
         super.conditionallyReattach(force);
         m_maskedPartsInitialized = temp;
         if(m_maskedPartsInitialized && needsRedraw)
         {
            if(this.m_isOpen)
            {
               for(index = 0; index < m_maskedParts.length - 1; index++)
               {
                  (m_maskedParts[index] as MaskedDecorationPart).conditionallyReattach(force);
               }
            }
            else
            {
               (m_maskedParts[m_maskedParts.length - 1] as MaskedDecorationPart).conditionallyReattach(force);
            }
         }
      }
      
      override public function attach() : void
      {
         var index:int = 0;
         var temp:Boolean = m_maskedPartsInitialized;
         m_maskedPartsInitialized = false;
         super.attach();
         m_maskedPartsInitialized = temp;
         if(m_maskedPartsInitialized)
         {
            if(this.m_isOpen)
            {
               for(index = 0; index < m_maskedParts.length - 1; index++)
               {
                  (m_maskedParts[index] as MaskedDecorationPart).attach();
               }
            }
            else
            {
               (m_maskedParts[m_maskedParts.length - 1] as MaskedDecorationPart).attach();
            }
         }
      }
      
      private function syncChanges() : void
      {
         var params:Object = new Object();
         params.x = Math.round(getPosition().x);
         params.y = Math.round(getPosition().y);
         params.isOpen = this.m_isOpen;
         params.state = getState();
         TransactionManager.addTransaction(new TMove(this,params));
      }
      
      override public function getCollisionFlags(x:int, y:int) : int
      {
         var collisionData:Vector.<int> = null;
         var idx:int = 0;
         var result:int = 0;
         if(this.m_isOpen)
         {
            collisionData = m_item.getCollisionData(this.m_openCollisionFlagIndex);
         }
         else
         {
            collisionData = m_item.getCollisionData(this.m_closedCollisionFlagIndex);
         }
         if(isRotated())
         {
            idx = x * m_item.sizeX + y;
         }
         else
         {
            idx = y * m_item.sizeX + x;
         }
         if(collisionData.length > idx)
         {
            result = collisionData[idx];
         }
         else
         {
            result = m_collisionFlags;
         }
         return result;
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
         var item:ContextMenuItem = null;
         if(event.target is ContextMenuItem)
         {
            item = event.target as ContextMenuItem;
            switch(item.action)
            {
               case ROTATE_OBJECT:
                  this.rotate();
                  break;
               case MOVE_OBJECT:
                  this.move();
                  break;
               case this.OPEN_OBJECT:
                  this.open(true);
                  break;
               case this.CLOSE_OBJECT:
                  this.open(false);
                  break;
               case SELL_OBJECT:
                  this.sell();
                  break;
               default:
                  super.onMenuClick(event);
            }
         }
      }
      
      override public function loadObject(data:Object) : void
      {
         super.loadObject(data);
         this.m_isOpen = data.isOpen;
         this.setAlpha(1);
      }
      
      override public function addTMoveParams(params:Object) : Object
      {
         super.addTMoveParams(params);
         params.isOpen = this.m_isOpen;
         return params;
      }
   }
}


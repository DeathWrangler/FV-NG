package Classes.UGC
{
   import Classes.UGCAnimal;
   import Classes.ZItem.IUGCItem;
   import Engine.Managers.TransactionManager;
   import Managers.DragonBreedingConfigManager;
   import Transactions.TCreateUGCItem;
   import com.adobe.images.PNGEncoder;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.net.URLRequestMethod;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class UGCDragonBreeding extends UGCAnimal implements IUGCMapResource
   {
      
      private var m_itemLayerState:UGCItemLayerState;
      
      private var m_itemState:UGCItemState;
      
      private var m_offspring:String;
      
      private var m_featureName:String = "dragon_pen_finished";
      
      public function UGCDragonBreeding(itemName:String, state:Dictionary = null)
      {
         var itemState:Object = null;
         var itemLayerState:Object = null;
         super(itemName);
         itemState = this.createState(state);
         this.m_itemState = UGCItemState.createFromServerState(itemState);
         m_ugcDelegate.ugcItemState = this.m_itemState;
         m_ugcDelegate.refresh();
      }
      
      public function createDragon() : void
      {
         var state:UGCItemState = this.m_itemState;
         if(state.isValid())
         {
            TransactionManager.addTransaction(new TCreateUGCItem(state,0,this,this.onCreateTxComplete),true);
         }
      }
      
      override public function getItemFriendlyName() : String
      {
         return Global.player.firstName + "\'s " + "Dragon";
      }
      
      override public function onMenuClick(event:MouseEvent) : void
      {
      }
      
      public function onCreation() : void
      {
         var totalCash:int = 0;
         var state:UGCItemState = this.m_itemState;
         if(state.isValid())
         {
            totalCash = 0;
            if(Global.player.canBuyCash(totalCash))
            {
               TransactionManager.addTransaction(new TCreateUGCItem(state,totalCash,this,this.onCreateTxComplete2),true);
            }
         }
      }
      
      private function onCreateTxComplete2(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var extraData:Object = null;
         var item:IUGCItem = null;
         var selectedObject:UGCAnimal = null;
         var UGCItemClass:Class = null;
         var mc:DisplayObject = null;
         var imageOfDragon:BitmapData = null;
         var imageArray:ByteArray = null;
         var loader:URLLoader = null;
         var url:String = null;
         var req:URLRequest = null;
         if(ugcItemState != null)
         {
            if(!existingItem)
            {
               extraData = {
                  "ugcUuid":ugcItemState.uuid,
                  "repopGift":false
               };
               item = this.getItem() as IUGCItem;
               UGCItemClass = item.farmItem.getMapResourceClass();
               selectedObject = new UGCItemClass(item.farmItem.name,ugcItemState.uuid) as UGCAnimal;
               selectedObject.drawDisplayObject();
               mc = selectedObject.getDisplayObject();
               imageOfDragon = this.snapClip(mc);
               imageArray = PNGEncoder.encode(imageOfDragon);
               loader = new URLLoader();
               url = "https://tkrishna-fv-zdev-22.farmville.com/createDragon.php?file=" + this.m_offspring + ".png";
               req = new URLRequest(url);
               req.requestHeaders = new Array(new URLRequestHeader("Content-Type","image/png"));
               loader.dataFormat = URLLoaderDataFormat.BINARY;
               req.contentType = "image/png";
               req.method = URLRequestMethod.POST;
               req.data = imageArray;
               loader.load(req);
            }
            else
            {
               existingItem.ugcDelegate.ugcItemState = ugcItemState;
            }
         }
      }
      
      private function onCreateTxComplete(ugcItemState:UGCItemState, existingItem:IUGCMapResource) : void
      {
         var extraData:Object = null;
         var item:IUGCItem = null;
         var selectedObject:UGCAnimal = null;
         var UGCItemClass:Class = null;
         var mc:DisplayObject = null;
         var imageOfDragon:BitmapData = null;
         var imageArray:ByteArray = null;
         var loader:URLLoader = null;
         var filename:String = null;
         if(ugcItemState != null)
         {
            if(!existingItem)
            {
               extraData = {
                  "ugcUuid":ugcItemState.uuid,
                  "repopGift":false
               };
               item = this.getItem() as IUGCItem;
               UGCItemClass = item.farmItem.getMapResourceClass();
               selectedObject = new UGCItemClass(item.farmItem.name,ugcItemState.uuid) as UGCAnimal;
               selectedObject.drawDisplayObject();
               mc = selectedObject.getDisplayObject();
               imageOfDragon = this.snapClip(mc);
               imageArray = PNGEncoder.encode(imageOfDragon);
               loader = new URLLoader();
               filename = this.m_offspring + ".png";
            }
            else
            {
               existingItem.ugcDelegate.ugcItemState = ugcItemState;
            }
         }
      }
      
      public function snapClip(clip:DisplayObject) : BitmapData
      {
         var bmpData:BitmapData = new BitmapData(200,200,true,0);
         bmpData.draw(clip,new Matrix());
         return bmpData;
      }
      
      private function createState(state:Dictionary) : Object
      {
         var itemState:Object = new Object();
         var bodyData:Object = new Object();
         var manesData:Object = new Object();
         var tailData:Object = new Object();
         var wingData:Object = new Object();
         var effectData:Object = new Object();
         var hornData:Object = new Object();
         var decalData:Object = new Object();
         bodyData["m"] = new Object();
         bodyData["e"] = new Object();
         bodyData["d"] = new Object();
         bodyData["w"] = new Object();
         bodyData["h"] = new Object();
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.HEAD_DATA_KEY]))
         {
            hornData["I"] = state[DragonBreedingConfigManager.HEAD_DATA_KEY];
            bodyData["h"] = hornData;
         }
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.PATTERN_DATA_KEY]))
         {
            manesData["I"] = state[DragonBreedingConfigManager.PATTERN_DATA_KEY];
            bodyData["m"] = manesData;
         }
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.WING_DATA_KEY]))
         {
            wingData["I"] = state[DragonBreedingConfigManager.WING_DATA_KEY];
            bodyData["w"] = wingData;
         }
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.FIRE_DATA_KEY]))
         {
            effectData["I"] = state[DragonBreedingConfigManager.FIRE_DATA_KEY];
            bodyData["e"] = effectData;
         }
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.NECK_DATA_KEY]))
         {
            decalData["I"] = state[DragonBreedingConfigManager.NECK_DATA_KEY];
            bodyData["d"] = decalData;
         }
         itemState["U"] = new String();
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.BODY_DATA_KEY]))
         {
            itemState["I"] = state[DragonBreedingConfigManager.BODY_DATA_KEY];
            itemState["D"] = new Object();
            itemState["D"] = bodyData;
         }
         if(Boolean(state) && Boolean(state[DragonBreedingConfigManager.SIBLING_ID]))
         {
            this.m_offspring = state[DragonBreedingConfigManager.SIBLING_ID];
         }
         return itemState;
      }
   }
}


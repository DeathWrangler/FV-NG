package Transactions
{
   import Classes.MystreeSapling;
   
   public class TMystreePlant extends TPlant
   {
      
      private var m_callback:Function;
      
      public function TMystreePlant(resource:MystreeSapling, isGift:Boolean = false, energySource:int = 0, energy:Number = 0, energyMetadata:Object = null, containerId:Number = 0, currency:String = "", callback:Function = null)
      {
         var mystreeSapling:MystreeSapling = null;
         super(resource,isGift,energySource,energy,energyMetadata,containerId,currency);
         if(resource is MystreeSapling)
         {
            mystreeSapling = resource as MystreeSapling;
            m_params.plotId = mystreeSapling.m_plotId;
         }
         this.m_callback = callback;
      }
      
      override protected function onComplete(result:Object) : void
      {
         super.onComplete(result);
         if(this.m_callback != null)
         {
            this.m_callback();
         }
      }
   }
}


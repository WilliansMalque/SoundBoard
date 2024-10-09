//
//  SoundViewController.swift
//  MalqueSoundBoard
//
//  Created by Willians Malque on 7/10/24.
//

import UIKit
import AVFoundation


class SoundViewController: UIViewController {
    
    
    
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var tiempoGrabacionLabel: UILabel!
    
    @IBOutlet weak var grabarButton: UIButton!
    
    @IBOutlet weak var reproducirButton: UIButton!
    
    @IBOutlet weak var nombreTextField: UITextField!
    
    @IBOutlet weak var agregarButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio : AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?
    var tiempoGrabacion: TimeInterval = 0
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        
        if grabarAudio!.isRecording {
                grabarAudio?.stop()
                grabarButton.setTitle("GRABAR", for: .normal)
                reproducirButton.isEnabled = true
                agregarButton.isEnabled = true
                timer?.invalidate()  // Detener temporizador
            } else {
                grabarAudio?.record()
                grabarButton.setTitle("DETENER", for: .normal)
                reproducirButton.isEnabled = false
                agregarButton.isEnabled = false
                tiempoGrabacion = 0  // Reiniciar contador
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
            }
    }
    
    @objc func actualizarTiempo() {
        tiempoGrabacion += 1
        tiempoGrabacionLabel.text = formatearTiempo(tiempoGrabacion)
    }
    
    func formatearTiempo(_ segundos: TimeInterval) -> String {
        let minutos = Int(segundos) / 60
        let segs = Int(segundos) % 60
        return String(format: "%02d:%02d", minutos, segs)
    }
    
    
    @IBAction func reproducirTapped(_ sender: Any) {
        
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.volume = volumeSlider.value // Establecer el volumen inicial
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {
            print("Error al reproducir el audio: \(error)")
        }
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
            
            // Guardar duración desde el temporizador
        grabacion.duracion = tiempoGrabacion  // Utilizar el tiempo grabado acumulado

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        
        volumeSlider.value = 1.0
        volumeSlider.addTarget(self, action: #selector(volumenCambiado), for: .valueChanged)

        // Do any additional setup after loading the view.
    }
    
    @objc func volumenCambiado(sender: UISlider) {
        reproducirAudio?.volume = sender.value // Ajustar el volumen del reproductor
    }
    
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo del audio
            
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los archivos
            
            print("*****************")
            print(audioURL!)
            print("*****************")
            
            //crear opciones para el grabador de audio
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de cgrabacion de audio
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

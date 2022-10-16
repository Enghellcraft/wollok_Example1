class Feria {
	var property puestos = #{}
	method agregarPuesto(puesto) {puestos.add(puesto)}
	method quePuestosPuedeUsarPersona(persona) =
		puestos.filter({puesto=>persona.puedoUsarPuesto(puesto)})
	method personaVisitoAlMenosUnPuesto(persona) = puestos.any({puesto=>(puesto.quienesUsaron()).contains(persona)})
	method cuantosPuestosApadrinaUnMunicipio(municipio) = puestos.count({puesto=>puesto.municipioQueLoApadrina()==municipio })
	method todosLosMunicipiosQueApadrinan() = (puestos.map({puesto=>puesto.municipioQueLoApadrina()})).asSet()
	method recaudacionTotalMunicipal() = (self.todosLosMunicipiosQueApadrinan()).sum({municipio=>municipio.recaudacionMunicipal()})
	method totalDeMunicipiosDeFeria() = (self.todosLosMunicipiosQueApadrinan()).size()
	method promedioRecaudacionDeMunicipios() = self.recaudacionTotalMunicipal() / self.totalDeMunicipiosDeFeria()
	method municipioQueMenosRecaudo() = self.todosLosMunicipiosQueApadrinan().min({municipio=>municipio.recaudacionMunicipal()})
}
class Persona {
	var property edad
	var property dineroDisponible
	var property municipioDeResidencia
	var property dineroQueDebeAMunicipio
	method anotarmeEnLista(puesto) {puesto.serUsadoPor(self)}
	method puedoUsarPuesto(puesto) = puesto.puedeSerUsadoPor(self)	
	method nopuedoUsarPuesto(puesto) {if (!puesto.puedeSerUsadoPor(self))
		{self.error("NO SE PUEDE!")} } 	
	method usarPuesto(puesto){
		self.nopuedoUsarPuesto(puesto)
		self.anotarmeEnLista(puesto) }
	method recibirPremio(premio) {dineroDisponible = dineroDisponible + premio}
	method pagarPuesto(costo) {dineroDisponible = dineroDisponible - costo}
	method deboAlMunicipio() = dineroQueDebeAMunicipio > 0
	method estoyLibreDeDeuda() = !self.deboAlMunicipio()
	method puedoPagarDeudaMunicipal() = dineroDisponible >= municipioDeResidencia.montoExigible(self)
	method pagarDeudaMunicipio(costo) {self.pagarPuesto(costo)
		dineroQueDebeAMunicipio = dineroQueDebeAMunicipio - costo }
	method cambioDeMunicipio(nuevoMunicipio) {municipioDeResidencia = nuevoMunicipio}
	method cambioDeEdad(nuevaEdad) {edad = nuevaEdad}
}
class Puesto {
	var property quienesUsaron = #{}
	var property municipioQueLoApadrina
	method puedeSerUsadoPor(persona)
	method serUsadoPor(persona) {quienesUsaron.add(persona)}
}
class PuestoDeJuegosYArte inherits Puesto {
	var property premio = 10
	method ganoPersonaDiezPesos(persona) {persona.recibirPremio(premio)}
	override method puedeSerUsadoPor(persona) = persona.edad() < 18
	override method serUsadoPor(persona) {
		self.ganoPersonaDiezPesos(persona)
		super(persona) }
}
class PuestoComercial inherits Puesto {
	var property costo
	method cobrarPersona(persona) {persona.pagarPuesto(costo)}
	override method puedeSerUsadoPor(persona) = persona.dineroDisponible() > costo
	override method serUsadoPor(persona) {
		self.cobrarPersona(persona)
		super(persona)}
}
class PuestoImpositivo inherits Puesto {
	method cobrarDeuda(persona) {
		const monto = self.montoExigible(persona)
		persona.pagarDeudaMunicipio(monto) 
		municipioQueLoApadrina.recibirPagoDeDeuda(monto) }
	method personaPerteneceAlMunicipio(persona) = (municipioQueLoApadrina.equals(persona.municipioDeResidencia()) )
	method personaDebeAlMunicipio(persona) = persona.deboAlMunicipio()
	method personaPuedePagarDeuda(persona) = persona.puedoPagarDeudaMunicipal()
	method montoExigible(persona) = municipioQueLoApadrina.montoExigible(persona)
	override method puedeSerUsadoPor(persona) = self.personaPerteneceAlMunicipio(persona) and
		self.personaDebeAlMunicipio(persona) and self.personaPuedePagarDeuda(persona)
	override method serUsadoPor(persona) {
		self.cobrarDeuda(persona)
		super(persona) }
}
class Municipio {
	var property recaudacionMunicipal = 0
	var property edadDiferencial = 75
	method montoBruto(persona)
	method montoProrrogable(persona) { if (persona.edad() > edadDiferencial) 
		{return self.porcentualMontoProrroga(persona)} else {return 0} }
	method porcentualMontoProrroga(persona) = (self.montoBruto(persona))*0.1
	method montoExigible(persona) = self.montoBruto(persona) - self.montoProrrogable(persona)
	method recibirPagoDeDeuda(monto) {recaudacionMunicipal = recaudacionMunicipal + monto}
}
class MunicipioNormal inherits Municipio {
	override method montoBruto(persona) = persona.dineroQueDebeAMunicipio()	
}
class TipoMunicipioRelajado inherits Municipio {
	override method montoBruto(persona) = (persona.dineroQueDebeAMunicipio()).min(persona.dineroDisponible())
}
class MunicipioRelajado inherits TipoMunicipioRelajado {
}
class MunicipioHiperrelajado inherits TipoMunicipioRelajado (edadDiferencial = 60) {
	override method montoBruto(persona) = super(persona) * 0.8
	override method montoProrrogable(persona) = super(persona) * 2
}





